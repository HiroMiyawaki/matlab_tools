function mail(text,subject,address)

    if nargin<3; address='miyawaki625@gmail.com';end
    if nargin<2; subject='mail from MatLab';end
    if nargin<1; text = datestr(now); end

    eval(['!echo -e "', text, '"|mail -s "', subject, '" ',address]);

end
