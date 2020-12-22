function AxisPos = myPlotPos(nCol, nRow, defPos)
% Position of diagrams - a very light SUBPLOT
% This is the percent offset from the subplot grid of the plot box.
% Formula: Space = a + b * n
% Increase [b] to increase the space between the diagrams.
% ======================================================================= %
% Author: Jan, Matlab Central
%         https://www.mathworks.com/matlabcentral/profile/authors/869888  %
% Date: 22 Sep 2011                                                       %
% ======================================================================= %
if nRow < 3
   BplusT = 0.18;
else
   BplusT = 0.09 + 0.045 * nRow;
end
if nCol < 3
   LplusR = 0.18;
else
   LplusR = 0.09 + 0.05 * nCol;
end
nPlot = nRow * nCol;
plots = 0:(nPlot - 1);
row   = (nRow - 1) - fix(plots(:) / nCol);
col   = rem(plots(:), nCol);
col_offset  = defPos(3) * LplusR / (nCol - LplusR);
row_offset  = defPos(4) * BplusT / (nRow - BplusT);
totalwidth  = defPos(3) + col_offset;
totalheight = defPos(4) + row_offset;
width       = totalwidth  / nCol - col_offset;
height      = totalheight / nRow - row_offset;
if width * 2 > totalwidth / nCol
   if height * 2 > totalheight / nRow
      AxisPos = [(defPos(1) + col * totalwidth / nCol), ...
            (defPos(2) + row * totalheight / nRow), ...
            width(ones(nPlot, 1), 1), ...
            height(ones(nPlot, 1), 1)];
   else
       AxisPos = [(defPos(1) + col * totalwidth / nCol), ...
            (defPos(2) + row * defPos(4) / nRow), ...
            width(ones(nPlot, 1), 1), ...
            (0.7 * defPos(ones(nPlot, 1), 4) / nRow)];
   end
else
   if height * 2 <= totalheight / nRow
      AxisPos = [(defPos(1) + col * defPos(3) / nCol), ...
            (defPos(2) + row * defPos(4) / nRow), ...
            (0.7 * defPos(ones(nPlot, 1), 3) / nCol), ...
            (0.7 * defPos(ones(nPlot, 1), 4) / nRow)];
   else
      AxisPos = [(defPos(1) + col * defPos(3) / nCol), ...
            (defPos(2) + row * totalheight / nRow), ...
            (0.7 * defPos(ones(nPlot, 1), 3) / nCol), ...
            height(ones(nPlot, 1), 1)];
    end
end

%% Calling
% figure;
% Rect    = [0.19, 0.07, 0.775, 0.845];
% AxisPos = myPlotPos(4, 4, Rect)
% for i = 1:16
%   axes('Position', AxisPos(i, :);
% end