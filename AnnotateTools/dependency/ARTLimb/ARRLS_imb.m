%% ARRLS revised to handle imbalanced data
%
%  Input:
%   - Xs, Xt: source samples, target samples
%   - Ys, Yt: source labels, target labels,
%   - optionARRLS: option for the original ARRLS
%   - optionIMB: option for revisions to handle imbalanced data
%  Output:
%   - initProb: probability from the internal classifier
%   - initCutoff: cutoff for the initProb
%   - finalScore: scores of each (training, test) samples, final output of this function
%   - finalCutoff: cutoff for the finalScore
%   - Ns, Nt: number of source (training) samples, target (test) samples
%
%  Reference: Mingsheng Long. Adaptation Regularization: A General Framework for Transfer Learning. TKDE 2012.
%
function [finalScore, finalCutoff, initProb, initCutoff, trainScore] = ARRLS_imb(Xs, Xt, Ys, Yt, optionARRLS, optionIMB)

    if ~exist('..\dependency\ARTLimb\liblinear\matlab', 'dir') 
        error('fail to find the library');
    end
    addpath(genpath('..\dependency\ARTLimb\liblinear\matlab'));

    % Check options
    if nargin < 6
        error('Function parameters should be set!');
    end
    if ~isfield(optionARRLS,'ker') || ...
            ~isfield(optionARRLS,'sigma') || ~isfield(optionARRLS,'lambda') || ...
            ~isfield(optionARRLS,'gamma') || ~isfield(optionARRLS,'p')
        error('ARRLS parameters should be set!');
    end
    if ~isfield(optionIMB,'BT') || ~isfield(optionIMB,'AC1') || ...
            ~isfield(optionIMB,'W') || ~isfield(optionIMB,'AC2')
        error('Imbalanced parameters should be set!');
    end
    
    fprintf('ARRLS started... \n');
    fprintf('\tker=%s, sigma=%f, lambda=%f, gamma=%f, p=%d\n',...
        optionARRLS.ker, optionARRLS.sigma, optionARRLS.lambda, optionARRLS.gamma, optionARRLS.p);
    fprintf('\tBT=%d, AC1=%d, W=[%d %d %d], AC2=%d\n',...
        optionIMB.BT, optionIMB.AC1, optionIMB.W(1), optionIMB.W(2), optionIMB.W(3), optionIMB.AC2);

    % Set predefined variables
    X = [Xs,Xt];
    Y = [Ys;Yt];
    Ns = size(Xs,2);    % number of source samples
    Nt = size(Xt,2);    % number of target samples
    Nst = Ns+Nt;        % number of all samples
    YY = [];
    for c = reshape(unique(Y),1,length(unique(Y)))
        YY = [YY,Y==c];
    end
    [~,Y] = max(YY,[],2);
    Ns_n = sum(Y(1:Ns) == 1);
    Ns_p = sum(Y(1:Ns) == 2);

    % Data normalization (into unit vector samples)
    X = X*diag(sparse(1./sqrt(sum(X.^2))));

    % get pseudo labels of target samples
    if optionIMB.BT == 1    % balance training samples
        [Xtmp, Ytmp] = balanceOverMinor(sparse(X(:,1:Ns)), Y(1:Ns));
    else
        Xtmp = X(:,1:Ns);   Ytmp = Y(1:Ns); 
    end
    model = train(Ytmp,sparse(Xtmp'),'-s 0 -c 1 -q 1');
    [~,~,initProb] = predict(Y(Ns+1:end),sparse(X(:,Ns+1:end)'),model,'-b 1');
    initProb = initProb(:, 2);  % probability of positive class
    
    if optionIMB.AC1 == false   % if adaptive cutoff flag is off
        initCutoff = 0.5;
    elseif optionIMB.AC1 == true  % estimate cutoff by fitting
        initCutoff = getCutoff_FL(initProb);
        %[initCutoff, mu1, sigma1, mu2, sigma2, xgrid] = getCutoff_FL(initProb);
    else
        error('unsupported adaptive cutoff option');
    end
%     % for debugging
%     bFlagGMM = 0;
%     Nt_n = sum(Yt == 0);
%     trueLabel = [zeros(Nt_n, 1); ones(Nt-Nt_n, 1)];
%     bestCutoff = getCutoff_BEST(trueLabel, initProb, 'avrAcc', 100);
%     plotGMMs(initProb, mu1, sigma1, mu2, sigma2, xgrid, ...
%         ['(' num2str(bFlagGMM, '%d') ') m1, s1, m2, s2, cut, bestC: ' ...
%           num2str(mu1, '%.2f') ', ' num2str(sigma1, '%.2f') ', ' ...
%           num2str(mu2, '%.2f') ', ' num2str(sigma2, '%.2f') ', ' ...
%           num2str(initCutoff, '%.2f') ', ' num2str(bestCutoff, '%.2f')]);
%     img = getframe(figure(2));
%     imwrite(img.cdata, [datestr(now, 'HHMMSSFFF') '.png']);
%     finalScore = initProb;  % kyung
%     finalCutoff = abs(bestCutoff-initCutoff);   % kyung
    
    %
    Yp = double(initProb > initCutoff) + 1;         % classes 1, 2
    Nt_n = sum(Yp==1);
    Nt_p = sum(Yp==2);

	Yp_tmp = double(initProb > 0.5) + 1;
	Nt_tmp_n = sum(Yp_tmp==1);
	Nt_tmp_p = sum(Yp_tmp==2);
    
    % a diagonal label indicator matrix
    if optionIMB.W(1) == 0  % if weighted ARRLS flag is off
        E = diag(sparse([ones(Ns,1);zeros(Nt,1)]));
    elseif optionIMB.W(1) == 1  % for imbalanced data
        E = diag(sparse([ones(Ns_n,1)*Ns/(2*Ns_n);ones(Ns_p,1)*Ns/(2*Ns_p);zeros(Nt,1)]));
    elseif optionIMB.W(1) == 2  % for imbalanced data, adaptively
        if Ns_n == Ns_p
            E = diag(sparse([ones(Ns,1);zeros(Nt,1)]));
        elseif Ns_n < Ns_p  % if negative is the minor class
			if Nt_tmp_n < Ns_n % use the original method
				E = diag(sparse([ones(Ns,1);zeros(Nt,1)]));
			else 	
				E = diag(sparse([ones(Ns_n,1)*Ns/(2*Ns_n);ones(Ns_p,1)*Ns/(2*Ns_p);zeros(Nt,1)]));
			end
        else
			if Nt_tmp_p < Ns_p % use the original method
				E = diag(sparse([ones(Ns,1);zeros(Nt,1)]));
			else 	
				E = diag(sparse([ones(Ns_n,1)*Ns/(2*Ns_n);ones(Ns_p,1)*Ns/(2*Ns_p);zeros(Nt,1)]));
			end
        end
    else
        error('unsupported weighted ARRLS option');
    end
    
    % Construct MMD matrix
    if optionIMB.W(2) == 0  % if weighted ARRLS flag is off
        e = [1/Ns*ones(Ns,1);-1/Nt*ones(Nt,1)];
    elseif optionIMB.W(2) == 1  % for imbalanced data
        e = zeros(Nst,1);
        e(Y(1:Ns)==1) = 1/Ns_n;      % source negative
        e(Y(1:Ns)==2) = 1/Ns_p;      % source positive
        e(Ns+find(Yp==1)) = -1/Nt_n;   % target negative
        e(Ns+find(Yp==2)) = -1/Nt_p;   % target positive
    elseif optionIMB.W(2) == 2  % for imbalanced data, adaptively
        if Ns_n == Ns_p
				e = [1/Ns*ones(Ns,1);-1/Nt*ones(Nt,1)];
        elseif Ns_n < Ns_p  % if negative is the minor class
			if Nt_tmp_n < Ns_n % use the original method
				e = [1/Ns*ones(Ns,1);-1/Nt*ones(Nt,1)];
			else 	
				e = zeros(Nst,1);
				e(Y(1:Ns)==1) = 1/Ns_n;      % source negative
				e(Y(1:Ns)==2) = 1/Ns_p;      % source positive
				e(Ns+find(Yp==1)) = -1/Nt_n;   % target negative
				e(Ns+find(Yp==2)) = -1/Nt_p;   % target positive
			end
        else
			if Nt_tmp_p < Ns_p % use the original method
				e = [1/Ns*ones(Ns,1);-1/Nt*ones(Nt,1)];
			else 	
				e = zeros(Nst,1);
				e(Y(1:Ns)==1) = 1/Ns_n;      % source negative
				e(Y(1:Ns)==2) = 1/Ns_p;      % source positive
				e(Ns+find(Yp==1)) = -1/Nt_n;   % target negative
				e(Ns+find(Yp==2)) = -1/Nt_p;   % target positive
			end
        end
    else
        error('unsupported weighted ARRLS option');
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
    manifold.k = optionARRLS.p;
    manifold.Metric = 'Cosine';
    manifold.NeighborMode = 'KNN';
    manifold.WeightMode = 'Cosine';
    W = graph_ARTL(X',manifold);
    if optionIMB.W(3) == 1  % for imbalanced data
        W(Y(1:Ns)==1, :) = W(Y(1:Ns)==1, :) * Nst / (2 * (Ns_p+Nt_p));
        W(Y(1:Ns)==2, :) = W(Y(1:Ns)==2, :) * Nst / (2 * (Ns_n+Nt_n));
        W(Ns+find(Yp==1), :) = W(Ns+find(Yp==1), :) * Nst / (2 * (Ns_p+Nt_p));
        W(Ns+find(Yp==2), :) = W(Ns+find(Yp==2), :) * Nst / (2 * (Ns_n+Nt_n));
    end
    Dw = diag(sparse(sqrt(1./sum(W))));
    L = speye(Nst)-Dw*W*Dw;
    
    % Adaptation Regularization based Transfer Learning: ARRLS
    K = kernel(optionARRLS.ker, X, sqrt(sum(sum(X.^2).^0.5)/Nst));
    Alpha = ((E + optionARRLS.lambda*M + optionARRLS.gamma*L)*K + optionARRLS.sigma*speye(Nst,Nst)) \ (E*YY);
    F = K*Alpha;
    
    score = F(:, 2) - F(:, 1);
    trainScore = score(1:Ns);
    finalScore = score(Ns+1:end);

    if optionIMB.AC2 == false   % if adaptive cutoff flag is off
        finalCutoff = 0.0;
    elseif optionIMB.AC2 == true  % best cutoff
        finalCutoff = getCutoff_FL(finalScore);
    else
        error('unsupported adaptive cutoff option');
    end
    
    rmpath(genpath('..\dependency\ARTLimb\liblinear\matlab'));    
    fprintf('ARRLS terminated... \n');
end
