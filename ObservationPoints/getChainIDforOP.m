function op_c = getChainIDforOP(chainList)
% A for loop :(
op_c = zeros(sum(chainList(:,3)),1);
for i = 1:size(chainList,1)-1
    op_c(chainList(i,2):chainList(i+1,2)-1) = i;
end
op_c(chainList(end,2):end)=size(chainList,1);
end