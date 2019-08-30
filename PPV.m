function PPV = PPV(probs, prior_p)
% compute the positive predicted value and print it

PPV = zeros([size(probs,1) length(prior_p)]);

count_p = 1;
for p = prior_p
    PPV(:,count_p) = probs(:,2)*p ./ ( probs(:,2)*p + probs(:,1)*(1-p) );
    count_p = count_p + 1;
end