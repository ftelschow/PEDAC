function X = generate_AR(Msim, N, rho, sigma, rho_se)
  if nargin < 5
      rho_se = 0;
  end
  
  if rho_se ~= 0
      rho1 = max(rho + normrnd(0, rho_se, [1,Msim]), 0);
  else
      rho1 = repmat(rho, [1, Msim]);
  end
  
  % Generate AR process with AR parameter rho and marginal variance 1
  X = zeros([N,Msim]);
  for m = 1:Msim
      eps = normrnd(0,1,[1,N]);
      
      X(1,m) = eps(1);
      for i = 2:N
          X(i,m) = rho1(m)*X(i-1,m) + sqrt(1-rho1(m)^2)*eps(i);
      end
  end
X = sigma*X;