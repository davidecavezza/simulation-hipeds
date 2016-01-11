function [ t ] = pretty_printer( s )
% Inserts newline & tab in the generated vrml code
% this is not perfect and simple 
t = '';
ctr = 0;
ii = 1;
jj = 1;

while ii < length(s)    
    [word, startIdx, endIdx] = getNextWord(s, ii);
    if ~isempty(strfind('{[',word))
        % insert newline & tabs, update jj
        [t, ii, jj] = copy(s, t, jj, startIdx, endIdx);
        [t, jj, ctr] = insertNT(t, jj, ctr+1);
    elseif ~isempty(strfind('}]',word))
        % insert newline, tabs, close bracket, newline & tab. update jj
        [t, jj, ctr]= insertNT(t, jj, ctr-1);
        [t, ii, jj] = copy(s, t, jj, startIdx, endIdx);
        [t, jj, ctr]= insertNT(t, jj, ctr);
    else
        [t, ii, jj] = copy(s, t, jj, startIdx, endIdx);            
        
        % Look ahead once for special cases
        [nextWord, nextStartIdx, nextEndIdx] = getNextWord(s, ii);
        if ~isempty(strfind('}]',nextWord))
            % insert newline, tabs, close bracket, newline & tab. update jj
            [t, jj, ctr]= insertNT(t, jj, ctr-1);
            [t, ii, jj] = copy(s, t, jj, nextStartIdx, nextEndIdx);
            [t, jj, ctr]= insertNT(t, jj, ctr);
        elseif isNumericStr(word)
            if ~isempty(strfind(word,','))                                
                [t, jj, ctr] = insertNT(t, jj, ctr);    
            end
            % if it is a number, look ahead and if the next one is not a
            % number, insert a new line and move on
            if ~isNumericStr(nextWord) && isempty(strfind('}]',nextWord))                
                [t, jj, ctr] = insertNT(t, jj, ctr);                
            end
        elseif ~isempty(strfind('NULL FALSE TRUE',word))            
            [t, jj, ctr] = insertNT(t, jj, ctr);        
        end        
    end

end

end

function [nextWord, startIdx, endIdx] = getNextWord(s, idx)
    ii = idx;
    % find beginning of next word
    while strcmp(s(ii),' ') 
        ii = ii+1;
    end
    nextWord = '';
    jj = 1;
    startIdx = ii;
    % find end of the word
    while ii <= length(s) && ~strcmp(s(ii),' ')
        nextWord(jj) = s(ii);
        jj = jj+1;
        ii = ii+1;
    end
    endIdx = ii-1;
end

function [bool] = isNumericStr(word)
    numericRegex = '((-?\d+)(\.\d+)?)(e-\d+)?|-?(\.\d+)';
    matched = regexp(word,numericRegex,'match');
    bool = ~isempty(matched); % nothing matched = no digit    
end

function [t, jj, ctr] = insertNT(t, jj, ctr)
    t(jj:jj+1) = '\n';
    jj = jj + 2;
    for ii = 1:ctr
        t(jj:jj+1) = '\t';
        jj = jj + 2;
    end    
end

function [t,ii,jj] = copy(s, t, jj, startIdx, endIdx)
    % +1 is for the white space. if at the end of str, minus it (hacky!)
    if endIdx == length(s)
        endIdx = endIdx - 1;
    end
    t(jj:jj+(endIdx+1-startIdx)) = s(startIdx:endIdx+1);    
    ii = endIdx+1;
    jj = jj+(endIdx+1-startIdx)+1;
end