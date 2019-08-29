function CumSumProb = CumDetectTimeProb(processMat, thresh)
  % Probability that detection time is greater than t
  detect = processMat;
  for j = 1:size(detect,2)
    detect(:,j) = cumsum(processMat(:,j) < thresh) > 0;
  end
  CumSumProb = mean(detect,2);