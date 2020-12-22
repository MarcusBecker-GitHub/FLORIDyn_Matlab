function [remainingTime] = timeEst(timeMeasured, numOfOperationsLeft)
% Gets a measured time and adds it to a set of already measured times
% Returns a string that estimates how long the program will need to finish

%Number of consecutive measurements
sizeTimeArray=10;

% get array with saved times
persistent MeasuredTimes;

% if the array is empty or no input argument was given the array is set to
% zeros
if nargin==0||isempty(MeasuredTimes)
    MeasuredTimes=zeros(sizeTimeArray,1);
    % if there is no input, MeasuredTimes is supposed to be reset
    if nargin==0
        %Mind that when resetting timeEst it will automatically use 
        % sizeTimeArray=10;
        remainingTime='0';
        return
    end
end

%create an array A for shifting the values in 'MeasuredTimes'
A=zeros(sizeTimeArray);
A(2:end,1:end-1)=eye(sizeTimeArray-1);

%Shift the values
MeasuredTimes=A*MeasuredTimes;

%Save the new measurement
MeasuredTimes(1,1)=timeMeasured;

% If not enough measurements yet
if sum(MeasuredTimes==0)>0
    remainingTime = '... estimating';
    return
end

%Calculate mean of saved times
meanTime=mean(MeasuredTimes);

%multiply the number of operations left with the mean time to get the
%remaining time
restTime=meanTime*numOfOperationsLeft;

%Change the format of the remaining time to a string and return the string
remainingTime=datestr(restTime/86400, 'HH:MM:SS');
end