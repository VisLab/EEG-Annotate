%% Mingsheng Long. Adaptation Regularization: A General Framework for Transfer Learning. TKDE 2012.
% revised by Kyung Min Su and Kay Robbins
function [finalScores, finalCutoff, initProbs, initCutoff,  trainScores, Alpha] ...
                                    = ARRLS(Xs, Xt, Ys, Yt, params)

  %% Set up the defaults and process the input arguments
    params = processAnnotateParameters('ARRLS', nargin, 4, params);
    p = params.ARRLSP;
    sigma = params.ARRLSSigma;
    lambda = params.ARRLSLambda;
    gamma = params.ARRLSGamma;
    ker = params.ARRLSKernel;
      
    if params.verbose
        fprintf('p=%d  sigma=%f  lambda=%f  gamma=%f\n',p,sigma,lambda,gamma);
    end
    
    %% Create pseudo labels if none exist
    fYt0 = true;
    if isempty(Yt)
        fYt0 = false;
        Yt = zeros(size(Xt, 2), 1);    % for temporary, use all zero labels.
    end
    %initCutoff = 0.5;
    
    %% Set predefined variables
    X = [Xs,Xt];
    Y = [Ys;Yt];
    Ns = size(Xs, 2);
    Nt = size(Xt, 2);
    Nst = Ns + Nt;
    
    %E = diag(sparse([ones(n,1);zeros(m,1)]));
    YY = [];
    for c = reshape(unique(Y),1,length(unique(Y)))
        YY = [YY, Y==c]; %#ok<AGROW>
    end
    [~,Y] = max(YY, [], 2);
    Ns_n = sum(Y(1:Ns) == 1);
    Ns_p = sum(Y(1:Ns) == 2);
    
    %% Data normalization
    X = X*diag(sparse(1./sqrt(sum(X.^2))));
    
    %% Handle the pseudolabels
    if fYt0 == false
        % get pseudo labels of target samples
        Xtmp = X(:,1:Ns);  
        Ytmp = Y(1:Ns);
        
        model = train(Ytmp, sparse(Xtmp'),'-s 0 -c 1 -q 1');
        [~,~,initProbs] = predict(Y(Ns+1:end),sparse(X(:,Ns+1:end)'),model,'-b 1');
        initProbs = initProbs(:, 2);  % probability of positive class      
        initCutoff = 0.5;
        Yp = double(initProbs > initCutoff) + 1;         % classes 1, 2
    else
        initProbs = [];
        initCutoff = 0;
        Yp = Y(Ns+1:end);
    end
    
    %% Create the other options
        Nt_n = sum(Yp==1);
    Nt_p = sum(Yp==2);

	Yp_tmp = double(initProbs > 0.5) + 1;
	Nt_tmp_n = sum(Yp_tmp==1);
	Nt_tmp_p = sum(Yp_tmp==2);
  
    
    %% Construct MMD
      E = diag(sparse([ones(Ns,1);zeros(Nt,1)]));
    e = [1/Ns*ones(Ns,1);-1/Nt*ones(Nt,1)];
      M = e*e'*length(unique(Y(1:Ns)));
    for c = reshape(unique(Y(1:Ns)),1,length(unique(Y(1:Ns))))
        e = zeros(Nst,1);
        e(Y(1:Ns)==c) = 1/length(find(Y(1:Ns)==c));
        e(Ns+find(Yp==c)) = -1/length(find(Yp==c));
        e(isinf(e)) = 0;
        M = M + e*e';
    end
    M = M/norm(M,'fro');
    
    %% Construct graph Laplacian
    manifold.k = params.ARRLSP;
    manifold.Metric = 'Cosine';
    manifold.NeighborMode = 'KNN';
    manifold.WeightMode = 'Cosine';
    W = graph_ARTL(X',manifold);
    Dw = diag(sparse(sqrt(1./sum(W))));
    L = speye(Nst)-Dw*W*Dw;
      
    %% Adaptation Regularization based Transfer Learning: ARRLS
    K = kernel(ker, X, sqrt(sum(sum(X.^2).^0.5)/Nst));
    Alpha = ((E+lambda*M+gamma*L)*K+sigma*speye(Nst, Nst))\(E*YY);
    F = K*Alpha;
    
    score = F(:, 2) - F(:, 1);
    trainScores = score(1:Ns);
    finalScores = score(Ns+1:end);
    finalCutoff = 0.0;
end

