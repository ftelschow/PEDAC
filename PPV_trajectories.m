function PPV = PPV_trajectories(probs, prior_p, detect_times)
% compute the positive predicted value as bayesian probability
% trajectories
T   = size(probs,1);
PPV = zeros([T length(prior_p)]);

count_p = 1;
for p = prior_p
    for t = 1:T
        if t > detect_times(count_p)
            PPV(t,count_p) = probs(t,2)*PPV(t-1,count_p) ./ ...
                             ( probs(t,2)*PPV(t-1,count_p) + probs(t,1)*(1-PPV(t-1,count_p)) );        
        else
            PPV(t,count_p) = probs(t,2)*p ./ ( probs(t,2)*p + probs(t,1)*(1-p) );        
        end
    end
    count_p = count_p + 1;
end