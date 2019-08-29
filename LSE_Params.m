% Least squares loss between Joos model and observation
function loss = LSE_Params( x, data, obs, start_year, end_year )
  % calculate Joosmodel for some parameter x and past emission data
  tmp     = JoosModelFix( data, x);
  % differenz in indizes because of starting time.
  dI      = size(data,1)-size(obs,1);
  % find the indices for the year we define the loss on
  Ia      = find( data(:,1) == start_year );
  Ie      = find( data(:,1) == end_year );
  loss = mean( (tmp(Ia:Ie,2) - obs((Ia-dI):(Ie-dI),2)).^2 );