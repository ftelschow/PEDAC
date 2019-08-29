function [threshold, dyear, probs] = get_Detection(process, drift, thresholds, q)

ind_95 = zeros([1 length(thresholds)]);
d_5    = zeros([1 length(thresholds)]);

PT_baseOpt  = [];
PT_alterOpt = [];
Iopt        = 0;
d_5Opt      = Inf;

for i = 1:length(thresholds)
  [PT_base, PT_alter] = get_futureDetectProb(process, drift, thresholds(i));
  [~, I]    = min(abs(PT_alter - (1-q)));
  ind_95(i) = I;
  d_5(i)    = abs(PT_base(I) - q);
  if d_5Opt >= d_5(i)
      PT_baseOpt  = PT_base;
      PT_alterOpt = PT_alter;
      Iopt        = I;
      d_5Opt      = d_5(i);
      iOpt        = i;
  end
end

probs     = [PT_baseOpt, PT_alterOpt];
threshold = thresholds(iOpt);
dyear     = Iopt;


% figure(1), clf, hold on
% plot( process(:, 1:2000) + drift(2,:)'-drift(1,:)')
% plot( 1:size(process,1), repmat(threshold, [1, size(process,1)]), 'LineWidth', 2)
% plot( drift(2,:)'-drift(1,:)')
% hold off