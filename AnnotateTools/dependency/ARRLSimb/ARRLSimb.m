%% ARRLS revised to handle imbalanced data
%
%  Input:
%   - Xs, Xt: source samples, target samples
%   - Ys, Yt: source labels, target labels,
%   - optionARRLS: options for the original ARRLS
%   - optionIMB: options for revisions to handle imbalanced data
%  Output:
%   - initProb: probability from the internal classifier
%   - initCutoff: cutoff for the initProb
%   - finalScore: scores of each (training, test) samples, final output of this function
%   - finalCutoff: cutoff for the finalScore
%   - Ns, Nt: number of source (training) samples, target (test) samples
%
%  Reference: Mingsheng Long. Adaptation Regularization: A General Framework for Transfer Learning. TKDE 2012.
%
function [finalScores, finalCutoff, initProbs, initCutoff, trainScores] = ...
                          ARRLSimb(Xs, Xt, Ys, Yt, params)
%% ARRLS revised to handle imbalanced data
%
%  Parameters:
%    Xs, Xt       source samples, target samples
%    Ys, Yt       cell arrays of source labels, target labels,
%    optionARRLS  options for the original ARRLS
%    optionIMB    options for revisions to handle imbalanced data
%    finalScore   (output) training score difference between positive and negative
%    class

  %% Set up the defaults and process the input arguments
     params = processAnnotateParameters('ARRLSimb', nargin, 4, params);
%     p = params.ARRLSP;
%     sigma = params.ARRLSSigma;
%     lambda = params.ARRLSLambda;
%     gamma = params.ARRLSGamma;
%     ker = params.ARRLSKernel;
%     % Check options
%     if nargin < 6
%         error('Function parameters should be set!');
%     end
 
%     if ~isfield(optionIMB,'BT') || ~isfield(optionIMB,'AC1') || ...
%             ~isfield(optionIMB,'W') || ~isfield(optionIMB,'AC2')
%         error('Imbalanced parameters should be set!');
%     end
    
    fYt0 = true;
    if isempty(Yt)
        fYt0 = false;
        Yt = zeros(size(Xt, 2), 1);    % for temporary, use all zero labels.
    end
    
    if params.verbose
        fprintf('\tker=%s, sigma=%f, lambda=%f, gamma=%f, p=%d\n',...
            params.ARRLSKernel,  params.ARRLSSigma, ...
            params.ARRLSLambda,  params.ARRLSGamma,  params.ARRLSP);
        %     fprintf('\tBT=%d, AC1=%d, W=[%d %d %d], AC2=%d, fYt0=%d\n',...
        %         params.balanceTrain, params.ARRLSimbBalancePseudoTrain, ...
        %         optionIMB.W(1), optionIMB.W(2), optionIMB.W(3), optionIMB.AC2, fYt0);
    end
    % Set predefined variables
    X = [Xs,Xt];
    Y = [Ys;Yt];
    Ns = size(Xs,2);    % number of source samples
    Nt = size(Xt,2);    % number of target samples
    Nst = Ns+Nt;        % number of all samples
    YY = [];
    for c = reshape(unique(Y),1,length(unique(Y)))
        YY = [YY,Y==c]; %#ok<AGROW>
    end
    [~,Y] = max(YY,[],2);
    Ns_n = sum(Y(1:Ns) == 1);
    Ns_p = sum(Y(1:Ns) == 2);

    % Data normalization (into unit vector samples)
    X = X*diag(sparse(1./sqrt(sum(X.^2))));

    if fYt0 == false
        % get pseudo labels of target samples
        if params.balanceTrain    % balance training samples
            [Xtmp, Ytmp] = balanceOverMinor(sparse(X(:,1:Ns)), Y(1:Ns));
        else
            Xtmp = X(:,1:Ns);   Ytmp = Y(1:Ns); 
        end
        model = train(Ytmp,sparse(Xtmp'),'-s 0 -c 1 -q 1');
        [~,~,initProbs] = predict(Y(Ns+1:end),sparse(X(:,Ns+1:end)'),model,'-b 1');
        initProbs = initProbs(:, 2);  % probability of positive class

        if params.ARRLSimbBalancePseudoTrain
            initCutoff = getCutoffFL(initProbs, 30, 0.5);
        else
            initCutoff = 0.5;
        end
        Yp = double(initProbs > initCutoff) + 1;         % classes 1, 2
    else
        initProbs = [];
        initCutoff = 0;
        Yp = Y(Ns+1:end);
    end

    %
    Nt_n = sum(Yp==1);
    Nt_p = sum(Yp==2);

    % a diagonal label indicator matrix
    if params.ARRLSimbRiskReweighting
       E = diag(sparse([ones(Ns_n,1)*Ns/(2*Ns_n);ones(Ns_p,1)*Ns/(2*Ns_p);zeros(Nt,1)]));
    else
        E = diag(sparse([ones(Ns,1);zeros(Nt,1)]));
    end
    
    % Construct MMD matrix
    if params.ARRLSimbClassReweighting  % if weighted ARRLS flag is off
        e = zeros(Nst,1);
        e(Y(1:Ns)==1) = 1/Ns_n;      % source negative
        e(Y(1:Ns)==2) = 1/Ns_p;      % source positive
        e(Ns+find(Yp==1)) = -1/Nt_n;   % target negative
        e(Ns+find(Yp==2)) = -1/Nt_p;   % target positive
    else
        e = [1/Ns*ones(Ns,1);-1/Nt*ones(Nt,1)];
    end
	
    M = e*e'*length(unique(Y(1:Ns)));
    for c = reshape(unique(Y(1:Ns)),1,length(unique(Y(1:Ns))))
        e = zeros(Nst,1);
        e(Y(1:Ns)==c) = 1/length(find(Y(1:Ns)==c));
        e(Ns+find(Yp==c)) = -1/length(find(Yp==c));
        e(isinf(e)) = 0;
        M = M + e*e';
    end
    M = M/norm(M,'fro');

    % Construct graph Laplacian
    manifold.k = params.ARRLSP;
    manifold.Metric = 'Cosine';
    manifold.NeighborMode = 'KNN';
    manifold.WeightMode = 'Cosine';
    W = graph_ARTL(X',manifold);
    if params.ARRLSimbManifoldReweighting  % for imbalanced data
        W(Y(1:Ns)==1, :) = W(Y(1:Ns)==1, :) * Nst / (2 * (Ns_p+Nt_p));
        W(Y(1:Ns)==2, :) = W(Y(1:Ns)==2, :) * Nst / (2 * (Ns_n+Nt_n));
        W(Ns+find(Yp==1), :) = W(Ns+find(Yp==1), :) * Nst / (2 * (Ns_p+Nt_p));
        W(Ns+find(Yp==2), :) = W(Ns+find(Yp==2), :) * Nst / (2 * (Ns_n+Nt_n));
    end
    Dw = diag(sparse(sqrt(1./sum(W))));
    L = speye(Nst)-Dw*W*Dw;
    
    % Adaptation Regularization based Transfer Learning: ARRLS
    K = kernel(params.ARRLSKernel, X, sqrt(sum(sum(X.^2).^0.5)/Nst));
    Alpha = ((E + params.ARRLSLambda*M + params.ARRLSGamma*L)*K + ...
              params.ARRLSSigma*speye(Nst,Nst)) \ (E*YY);
    F = K*Alpha;
    
    score = F(:, 2) - F(:, 1);
    trainScores = score(1:Ns);
    finalScores = score(Ns+1:end);

    if params.ARRLSimbAdaptiveCutoff
        finalCutoff = getCutoffFL(finalScores, 30, 0.0);% if adaptive cutoff flag is off
    else
         finalCutoff = 0.0;
    end
end
