% (c) Jan Modersitzki 2010/12/27, see FAIR.2 and FAIRcopyright.m.
% http://www.mic.uni-luebeck.de/people/jan-modersitzki.html
%
% function [Tc,dT] = linearInter(T,omega,x,varargin)
%
% linear interpolator for the data T given on a cell-centered grid evaluated at x
% see �3.3 p24

function [Tc,dT] = linearInter(T,omega,x,varargin)
         
Tc = mfilename('fullpath'); dT = []; 

if nargin == 0, 
  runMinimalExample;
  return;
elseif nargin == 1 && isempty(T),
  return;
end;

% flag for computing the derivative
doDerivative = (nargout>1);
matrixFree   = 0;
for k=1:2:length(varargin), % overwrite default parameter
  eval([varargin{k},'=varargin{',int2str(k+1),'};']);
end;

% get data size m, cell size h, dimension d, and number n of interpolation points
dim = length(omega)/2;
m   = size(T);         if dim == 1, m = numel(T); end;
h   = (omega(2:2:end)-omega(1:2:end))./m;
n   = length(x)/dim;
x   = reshape(x,n,dim);

% map x from [h/2,omega-h/2] -> [1,m],
for i=1:dim, x(:,i) = (x(:,i)-omega(2*i-1))/h(i) + 0.5; end;

Tc = zeros(n,1); dT = [];                     % initialize output
if doDerivative, dT = zeros(n,dim);  end;     % allocate memory in column format
Valid = @(j) (0<x(:,j) & x(:,j)<m(j)+1);      % determine indices of valid points

switch dim,
  case 1, valid = find( Valid(1) );   
  case 2, valid = find( Valid(1) & Valid(2) );   
  case 3, valid = find( Valid(1) & Valid(2) & Valid(3) );   
end;

if isempty(valid),                        
  if doDerivative, dT = sparse(n,dim*n); end; % allocate memory incolumn format
  return; 
end;

pad = 1; TP = zeros(m+2*pad);                 % pad data to reduce cases

P = floor(x); x = x-P;                        % split x into integer/remainder
p = @(j) P(valid,j); xi = @(j) x(valid,j);

% increments for linearized ordering
i1 = 1; i2 = size(T,1)+2*pad; i3 = (size(T,1)+2*pad)*(size(T,2)+2*pad);

switch dim,
  case 1, 
    TP(pad+(1:m)) = reshape(T,m,1);
    clear T;
    p = pad + p(1);
    Tc(valid) = TP(p).* (1-xi(1)) + TP(p+1).*xi(1);   % compute weighted sum
    
    if ~doDerivative, return; end;             
    % compute and format the derivative
    dT(valid) = TP(p+1)-TP(p);
  case 2, 
    TP(pad+(1:m(1)),pad+(1:m(2))) = T;
    clear T;
    p  = (pad + p(1)) + i2*(pad + p(2) - 1);
    % compute Tc as weighted sum
    Tc(valid) = (TP(p)   .* (1-xi(1)) + TP(p+i1)    .*xi(1)) .* (1-xi(2)) ...
      + (TP(p+i2) .* (1-xi(1)) + TP(p+i1+i2) .*xi(1)) .* (xi(2));
  
    if ~doDerivative, return; end;
    dT(valid,1) = (TP(p+i1)-TP(p)).*(1-xi(2)) + (TP(p+i1+i2)-TP(p+i2)).*xi(2);
    dT(valid,2) = (TP(p+i2)-TP(p)).*(1-xi(1)) + (TP(p+i1+i2)-TP(p+i1)).*xi(1);
  case 3, 
    TP(pad+(1:m(1)),pad+(1:m(2)),pad+(1:m(3))) = T;
    clear T;
    p  = (pad + p(1)) + i2*(pad + p(2) - 1) + i3*(pad + p(3) -1);
    % compute Tc as weighted sum
    Tc(valid) = ((TP(p).*(1-xi(1))+TP(p+i1).*xi(1)).*(1-xi(2))...
      +(TP(p+i2).*(1-xi(1))+TP(p+i1+i2).*xi(1)).*(xi(2))).*(1-xi(3)) ...
      +((TP(p+i3).*(1-xi(1))+TP(p+i1+i3).*xi(1)).*(1-xi(2)) ...
      +(TP(p+i2+i3).*(1-xi(1))+TP(p+i1+i2+i3).*xi(1)).*(xi(2))).*(xi(3));
    
    if ~doDerivative, return; end;
    dT(valid,1) = ((TP(p+i1)-TP(p)).*(1-xi(2))+(TP(p+i1+i2)-TP(p+i2)).*xi(2)).*(1-xi(3)) ...
      +((TP(p+i1+i3)-TP(p+i3)).*(1-xi(2))+(TP(p+i1+i2+i3)-TP(p+i2+i3)).*xi(2)).*(xi(3));
    dT(valid,2) = ((TP(p+i2)-TP(p)).*(1-xi(1))+(TP(p+i1+i2)-TP(p+i1)).*xi(1)).*(1-xi(3)) ...
      +((TP(p+i2+i3)-TP(p+i3)).*(1-xi(1))+(TP(p+i1+i2+i3)-TP(p+i1+i3)).*xi(1)).*(xi(3));
    dT(valid,3) = ((TP(p+i3).*(1-xi(1))+TP(p+i1+i3).*xi(1)).*(1-xi(2)) ...
      +(TP(p+i2+i3).*(1-xi(1))+TP(p+i1+i2+i3).*xi(1)).*(xi(2))) ....
      -((TP(p).*(1-xi(1))+TP(p+i1).*xi(1)).*(1-xi(2)) ...
      +(TP(p+i2).*(1-xi(1))+TP(p+i1+i2).*xi(1)).*(xi(2)));
end;
if doDerivative
    for i=1:dim, dT(:,i) = dT(:,i)/h(i); end
    if not(matrixFree)
        dT = spdiags(dT,n*(0:(dim-1)),n,dim*n);
    end
end

function runMinimalExample
help(mfilename);
fprintf('%s: minimal examples\n',mfilename)

% 1D example
omega = [0,10];
TD    = [0,1,4,1,0]; 
m     = length(TD);
XD    = getCellCenteredGrid(omega,m);
xc    = linspace(-1,11,101);
[T0,dT0] = feval(mfilename,TD,omega,xc);

figure(1); 
subplot(1,2,1); plot(xc,T0,'b-',XD,TD,'ro'); 
title(sprintf('%s %d-dim',mfilename,1));
subplot(1,2,2); spy(dT0);                     
title('dT')

% 2D example
omega = [0,10,0,8];
TD    = [1,2,3,4;1,2,3,4;4,4,4,4]; m = size(TD);
XD    = getCellCenteredGrid(omega,m);
xc    = getCellCenteredGrid(omega+[-1 1 -1 1],5*m);
[Tc,dT] = feval(mfilename,TD,omega,xc);
DD = reshape([XD;TD(:)],[],3);
Dc = reshape([xc;Tc],[5*m,3]);

figure(2); clf;
subplot(1,2,1);  surf(Dc(:,:,1),Dc(:,:,2),Dc(:,:,3));  hold on;
plot3(DD(:,1),DD(:,2),DD(:,3),'r.','markersize',40); hold off;
title(sprintf('%s %d-dim',mfilename,2));
subplot(1,2,2); spy(dT);                     
title('dT')

% 3D example
omega = [0,1,0,2,0,1]; m = [13,16,7];
XD    = getCellCenteredGrid(omega,m);
Y     = reshape(XD,[m,3]);
TD    = (Y(:,:,:,1)-0.5).^2 + (Y(:,:,:,2)-0.75).^2 + (Y(:,:,:,3)-0.5).^2 <= 0.15;
TD    = reshape(TD,m);
xc    = getCellCenteredGrid(omega,4*m);
[Tc,dT] = feval(mfilename,TD,omega,xc);

figure(3); clf;
subplot(1,2,1); imgmontage(Tc,omega,4*m);
title(sprintf('%s %d-dim',mfilename,3));
subplot(1,2,2); spy(dT);                 
title('dT')

%{ 
	=======================================================================================
	FAIR: Flexible Algorithms for Image Registration, Version 2011
	Copyright (c): Jan Modersitzki
	Maria-Goeppert-Str. 1a, D-23562 Luebeck, Germany
	Email: jan.modersitzki@mic.uni-luebeck.de
	URL:   http://www.mic.uni-luebeck.de/people/jan-modersitzki.html
	=======================================================================================
	No part of this code may be reproduced, stored in a retrieval system,
	translated, transcribed, transmitted, or distributed in any form
	or by any means, means, manual, electric, electronic, electro-magnetic,
	mechanical, chemical, optical, photocopying, recording, or otherwise,
	without the prior explicit written permission of the authors or their
	designated proxies. In no event shall the above copyright notice be
	removed or altered in any way.

	This code is provided "as is", without any warranty of any kind, either
	expressed or implied, including but not limited to, any implied warranty
	of merchantibility or fitness for any purpose. In no event will any party
	who distributed the code be liable for damages or for any claim(s) by
	any other party, including but not limited to, any lost profits, lost
	monies, lost data or data rendered inaccurate, losses sustained by
	third parties, or any other special, incidental or consequential damages
	arrising out of the use or inability to use the program, even if the
	possibility of such damages has been advised against. The entire risk
	as to the quality, the performace, and the fitness of the program for any
	particular purpose lies with the party using the code.
	=======================================================================================
	Any use of this code constitutes acceptance of the terms of the above statements
	=======================================================================================
%}