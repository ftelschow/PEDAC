function [probs, dyear, probs2] = get_Detection3(process, drift, thresholds, q)

true_detect  = zeros([1 length(thresholds)]);
false_detect = zeros([1 length(thresholds)]);

N = size(process,2);
T = size(process,1);

%process_shift = process;
for t = 1:T
    if t==1
        mProc = process(1,:);
    else
        v      = ones([t N])*NaN;
        v(1,:) = process(1,:);
        for tt = 2:t
            v(tt,:) = mean(process(1:tt,:));
        end
        mProc = min(v);
    end
    false_detect(t) = sum( mProc < thresholds(t) ) / N;
end

process_shift = process + drift(2,:)'-drift(1,:)';
for t = 1:T
    if t==1
        mProc = process_shift(1,:);
    else
        v      = ones([t N])*NaN;
        v(1,:) = process_shift(1,:);
        for tt = 2:t
            v(tt,:) = mean(process_shift(1:tt,:));
        end
        mProc = min(v);
    end
    true_detect(t) = sum( mProc < thresholds(t) ) / N;
end

%false_detect2 = CumDetectTimeProb( process -thresholds', 0 )';
%true_detect2  = CumDetectTimeProb( process + drift(2,:)'-drift(1,:)'-thresholds',...
%                                       0);
true_detect2  = zeros([1 length(thresholds)]);
false_detect2 = zeros([1 length(thresholds)]);
%                                    
% for k = 1:length(thresholds)
%     tmp = CumDetectTimeProb( process, thresholds(k) );
%     false_detect2(k) = tmp(k);
%     tmp = CumDetectTimeProb( process + drift(2,:)'-drift(1,:)', thresholds(k) );
%     true_detect2(k)  = tmp(k);   
% end

probs  = [false_detect; true_detect]';
probs2 = [false_detect2; true_detect2]';

[~,dyear] = min(abs(true_detect-(1-q)));


% figure(1), clf, hold on
% plot( process(:, 1:2000) + drift(2,:)'-drift(1,:)')
% plot( 1:T, thresholds, 'LineWidth', 2)
% plot( drift(2,:)'-drift(1,:)')
% hold off

% figure(2), hold on
% plot( process(:, 11:30))
% plot( [0, 50], [-threshold,-threshold], 'LineWidth', 2)
% plot( drift(2,:)'-drift(1,:)')
% hold off