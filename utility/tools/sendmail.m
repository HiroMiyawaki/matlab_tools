function sendmail(address,text,subject)

    if nargin<3; subject='mail from MatLab';end
    if nargin<2; text = datestr(now); end

    eval(['!echo -e "', text, '"|mail -s "', subject, '" ',address]);

end
