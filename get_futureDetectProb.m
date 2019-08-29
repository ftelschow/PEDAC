function [PT_base, PT_alter] = get_futureDetectProb(process, drift, threshold)
  PT_base  = ones([size(process,1) length(threshold)])*NaN;
  PT_alter = ones([size(process,1) length(threshold)])*NaN;
  
  % Get cummulative probability of detecting an exeedance for all
  % thresholds
  for i = 1:length(threshold)
    PT_base(:,i)  = CumDetectTimeProb( process, -threshold(i) );
    PT_alter(:,i) = CumDetectTimeProb( process + drift(2,:)'-drift(1,:)',...
                                       -threshold(i));
  end
  

% figure(1), hold on
% plot( process(:, 11:30) + drift(2,:)'-drift(1,:)')
% plot( [0, 50], [-threshold,-threshold], 'LineWidth', 2)
% plot( drift(2,:)'-drift(1,:)')
% hold off
% 
% figure(2), hold on
% plot( process(:, 11:30))
% plot( [0, 50], [-threshold,-threshold], 'LineWidth', 2)
% plot( drift(2,:)'-drift(1,:)')
% hold off