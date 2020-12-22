function [indOP,op_c] = op2Sorted(chainList)
% Returns the index vector with wich the Chains are sorted in a newest to
% oldest manner.
op_c = getChainIDforOP(chainList);
indOP = zeros(size(op_c));
for i = 1:size(chainList,1)
    % Get chain 
    start   = chainList(i,2);
    off     = chainList(i,1);
    len     = chainList(i,3);
    
    indOP(start:start+off)          =[off:-1:0]+start;
    indOP(start+off+1:start+len-1)  =[len-1:-1:off+1]+start;
end
end

% chainList
% [ off, start_id, length, t_id]