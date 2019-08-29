function X = generate_AR(Msim, N, rho, sigma)
  % Generate AR process with AR parameter rho and marginal variance 1
  X = zeros([N,Msim]);
  for m = 1:Msim
      eps = normrnd(0,1,[1,N]);
      X(1,m) = eps(1);
      for i = 2:N
          X(i,m) = rho*X(i-1,m) + sqrt(1-rho^2)*eps(i);
      end
  end
X = sigma*X;