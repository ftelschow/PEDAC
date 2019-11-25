% Least squares loss between Joos model and observation
function loss = LSE_Params( x, data, obs, start_year, end_year )
  % calculate Joosmodel for some parameter x and past emission data
  tmp     = JoosModel( data, x);
  
  % find the indices for the year we define the loss on
  I1a      = find( tmp(:,1) == start_year );
  I1e      = find( tmp(:,1) == end_year );
  I2a      = find( obs(:,1) == start_year );
  I2e      = find( obs(:,1) == end_year );
  
  % compute the loss as non weighted mean square
  loss = mean( ( tmp(I1a:I1e,2) - obs(I2a:I2e,2) ).^2 );