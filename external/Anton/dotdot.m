function c=dotdot(a,op,b)
%DOTDOT Generalized Element-by-Element Mathematics (DOTDOT Operations?).
% DOTDOT(A,OP,B) performs operation OP between A and B where N-dimensional
% A and B share equal sizes along all dimensions except for one or more
% dimensions where one is singleton and the other is not. In this case the
% mismatched singleton dimensions are expanded to match the other array's
% dimension and the chosen mathematical operation is performed.
%
% DOTDOT(OP) returns a function handle that evaluates DOTDOT(A,OP,B) when
% called with two arguments A and B. This function handle can be evaluated
% for different-sized arguments as needed. Each time it performs the
% expansion necessary to do perform the desired operation.
%
% OP may be one of the following strings representing their associated
% element-by-element mathematical or logical operations:
%
% '+'  '-'  '*'  '/'  '^'    '|'  '&'    '<'  '<='   '>'  '>='    '==' '~='
%
% OP may also be a function handle that evaluates a function of TWO
% arguments, both having the same dimensions (after internal expansion).
%
% For example, OP = @(A,B) (A-B)./B; computes the element-by-element
% relative difference between A and B. DOTDOT(OP) where OP is a function
% handle (like above), returns a function handle that can evaluate OP with
% different-sized inputs as needed. Each time it performs the expansion
% necessary to do perform the desired operation.
%
% Examples:
% A = ones(3,4);  B = [4 3 2 1];
% DOTDOT(A,'+',B) produces [5 4 3 2
%                           5 4 3 2
%                           5 4 3 2]
% DOTDOT(A,'+',B') produces an error since B' has 4 rows, but A has only 3.
%
% MYSUM = DOTDOT('+') returns a function handle so that MYSUM(A,B) produces
% the same result as above when called with the A and B shown above.
%
% Defining: MYFUN = @(A,B) (A-B)./B; and using the above input data
% DOTDOT(A,MYFUN,B) produces [-3/4 -2/3 -1/2 0
%                             -3/4 -2/3 -1/2 0
%                             -3/4 -2/3 -1/2 0]
%
% A = 2+zeros(3,4); B = [4 3 2 1];
% MYPOW = DOTDOT('^') returns a function handle for generalized .^ 
% DOTDOT(A,'^',B) and MYPOW(A,B) produce [16 8 4 2
%                                         16 8 4 2
%                                         16 8 4 2]
%
% MYPOW(B,A) and DOTDOT(B,'^',A) produce [16 9 4 1
%                                         16 9 4 1
%                                         16 9 4 1]
%
% X = rand(200,10); M = mean(X); MYDIFF = DOTDOT('-')
% DOTDOT(X,'-',M) and MYDIFF(X,M) subtracts the mean of the k-th column
% from the k-th column.
%
% See also REPMAT, OPS, FUNCTION_HANDLE

% D.C. Hanselman, University of Maine, Orono, ME 04469
% MasteringMatlab@yahoo.com
% Mastering MATLAB 7
% 2006-03-08

ops={'+' '-' '*' '/' '^' '|' '&' '<' '<=' '>' '>=' '==' '~='};
if nargin<1
   error('dotdot:NotEnoughInputArguments',...
      'At Least One Input Argument Required.')
end
if nargin==1
   OP=a;
   if ischar(OP) && any(strcmp(OP,ops))
      c=@(A,B) dotdot(A,OP,B);
      return
   elseif isa(OP,'function_handle')
      if nargin(OP)==2
         c=@(A,B) dotdot(A,OP,B);
         return
      else
         error('dotdot:ImproperFunction',...
               'Function Provided Must Accept Two Input Arguments.')
      end
   else
      error('dotdot:InvalidInput','Operator Unknown.')
   end
elseif nargin~=3
      error('dotdot:ImproperInputArgumentNumber',...
            'One or Three Input Arguments Required.')
end
% all three input arguments exist now
opsf={@(a,b)a+b @(a,b)a-b @(a,b)a.*b @(a,b)a./b @(a,b)a.^b ...
      @(a,b)a|b @(a,b)a&b @(a,b)a<b  @(a,b)a<=b @(a,b)a>b @(a,b)a>=b ...
      @(a,b)a==b @(a,b)a~=b};
if ~(isnumeric(a)||islogical(a)) || ~(isnumeric(b)||islogical(b))
   error('dotdot:InvalidInput','Inputs A and B Must be Numeric or Logical.')
end
if isa(op,'function_handle')
   if nargin(op)==2
      opfun=op; % user supplied function handle provided
   else
      error('dotdot:ImproperFunction',...
            'Function Provided Must Accept Two Input Arguments.')
   end
elseif ischar(op) && any(strcmp(op,ops))
   opfun=opsf{strcmp(op,ops)};   % function handle for operation requested
else
   error('dotdot:UnknownOperator','Operator Unknown.')
end
% now do generalized expansion
adim=ndims(a);
bdim=ndims(b);
asiz=[size(a) ones(1,bdim-adim)];	% make sizes the same by
bsiz=[size(b) ones(1,adim-bdim)];	% appending singletons as needed.
notsiz=asiz~=bsiz;                  % where size along dimensions differ
asing=asiz==1;                      % singleton dimensions
bsing=bsiz==1;

if any(notsiz&~(asing|bsing))
   error('dotdot:NonConformingInputs',...
      'Dimensions Where A and B Differ in Size, One Must be Singleton.')
end

if all(notsiz==0)             % no expansion needed, just do operation
   c=opfun(a,b);
else
   % replicating A and B to make them the same size is not memory efficient
   % but it greatly simplifies the solution here. If this were a built-in
   % function, it could be implemented in a more memory efficient manner.
   
   cdim=length(asiz);         % dimensions of output
   arep=ones(1,cdim);         % default replication is all ones
   brep=arep;
   arep(asing)=bsiz(asing);	% how much to replicate A to match B
   brep(bsing)=asiz(bsing);	% how much to replicate B to match A
   if any(arep~=1)            % replicate A if needed
      a=repmat(a,arep);
   end
   if any(brep~=1)            % replicate B if needed
      b=repmat(b,brep);
   end
   c=opfun(a,b);              % do the function requested
end