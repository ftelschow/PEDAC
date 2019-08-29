function thresholds = get_Thresholds(process, q)
  if nargin < 2
      q = 0.05;
  end
  T = size(process,1);
  
  thresholds = ones([1 T])*NaN;
  
  % Get cummulative probability of detecting an exeedance for all
  % thresholds
  for t = 1:T
    if t==1
        mProc = process(1,:);
    else
        mProc = min(process(1:t,:));
    end
    thresholds(t)  = quantile(mProc, q);
  end
