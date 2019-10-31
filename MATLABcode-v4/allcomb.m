function A = allcomb(varargin)
% ALLCOMB - All combinations: cartesian product.
error(nargchk(1,Inf,nargin)) ;

% check for empty inputs
q = ~cellfun('isempty',varargin) ;
if any(~q),
    warning('ALLCOMB:EmptyInput','Empty inputs result in an empty output.') ;
    A = zeros(0,nargin) ;
else
    
    ni = sum(q) ;
    
    argn = varargin{end} ;

    if ischar(argn) && (strcmpi(argn,'matlab') || strcmpi(argn,'john')),
        ni = ni-1 ;
        ii = 1:ni ;
        q(end) = 0 ;
    else
        % enter arguments backwards, so last one (AN) is changing fastest
        ii = ni:-1:1 ;
    end
    
    if ni==0,
        A = [] ;
    else
        args = varargin(q) ;
        if ni==1,
            A = args{1}(:) ;
        else
            % flip using ii if last column is changing fastest
            [A{ii}] = ndgrid(args{ii}) ;
            % concatenate
            A = reshape(cat(ni+1,A{:}),[],ni) ;
        end
    end
end