function h=text2(Xpos,Ypos,String,Axis,Property)

    if nargin<4
        Axis=axis();
    end
    if nargin<5
        Property={};
    end

    

    H=text(Axis(1:2)*[1-Xpos;Xpos],Axis(3:4)*[1-Ypos;Ypos],String,Property{:});
    if nargout>0
        h=H;
    end
    
    