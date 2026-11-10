function [decision, threshold, burstEnergy] = ...
    detect_signal(peakValue, referenceBurst, thresholdFraction)

% Energy of known reference burst
burstEnergy = sum(referenceBurst.^2);

% Initial detection threshold
threshold = thresholdFraction * burstEnergy;

% Decision
if peakValue > threshold
    decision = "SIGNAL DETECTED";
else
    decision = "NO SIGNAL DETECTED";
end

end