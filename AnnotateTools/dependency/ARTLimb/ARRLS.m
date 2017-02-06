%% Mingsheng Long. Adaptation Regularization: A General Framework for Transfer Learning. TKDE 2012.
% revised by Kyung
% - remove print out statement
% - return scores
function [finalScores, finalCutoff, initProbs, initCutoff, ...
    trainScores, Acc, Cls, Alpha] = ARRLS(Xs, Xt, Ys, Yt, params)

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
    initCutoff = 0.5;
    %% Set predefined variables
    X = [Xs,Xt];
    Y = [Ys;Yt];
    n = size(Xs,2);
    m = size(Xt,2);
    nm = n+m;
    E = diag(sparse([ones(n,1);zeros(m,1)]));
    YY = [];
    for c = reshape(unique(Y),1,length(unique(Y)))
        YY = [YY,Y==c]; %#ok<AGROW>
    end
    [~,Y] = max(YY, [], 2);
    
    %% Data normalization
    X = X*diag(sparse(1./sqrt(sum(X.^2))));
    
    %% Construct graph Laplacian
    manifold.k = params.ARRLSP;
    manifold.Metric = 'Cosine';
    manifold.NeighborMode = 'KNN';
    manifold.WeightMode = 'Cosine';
    W = graph_ARTL(X',manifold);
    Dw = diag(sparse(sqrt(1./sum(W))));
    L = speye(nm)-Dw*W*Dw;
    
    %% Construct MMD matrix
    if isempty(params.pseudoLabels)
        model = train(Y(1:n), sparse(X(:,1:n)'), '-s 0 -c 1 -q 1');
        [Cls, ~, initProbs] = predict(Y(n+1:end), sparse(X(:,n+1:end)'), model, '-b 1');
    else
        Cls = params.pseudoLabels;
    end
    e = [1/n*ones(n,1);-1/m*ones(m,1)];
    M = e*e'*length(unique(Y(1:n)));
    for c = reshape(unique(Y(1:n)),1,length(unique(Y(1:n))))
        e = zeros(n+m,1);
        e(Y(1:n)==c) = 1/length(find(Y(1:n)==c));
        e(n+find(Cls==c)) = -1/length(find(Cls==c));
        e(isinf(e)) = 0;
        M = M + e*e';
    end
    M = M/norm(M,'fro');
    
    %% Adaptation Regularization based Transfer Learning: ARRLS
    K = kernel(ker,X,sqrt(sum(sum(X.^2).^0.5)/nm));
    Alpha = ((E+lambda*M+gamma*L)*K+sigma*speye(nm,nm))\(E*YY);
    F = K*Alpha;
    [~, Cls] = max(F, [], 2);
    
    %% Compute accuracy
    Acc = numel(find(Cls(n+1:end)==Y(n+1:end)))/m;
    Cls = Cls(n+1:end);
    if params.verbose
        fprintf('>>Acc=%f\n',Acc);
    end
    
    %% Return score in addition to the labels
    score = F(:, 2) - F(:, 1);
    trainScores = score(1:n);
    finalScores = score(n+1:end);
    finalCutoff = 0.0;

end

