function [msg_bien_encode] = encode_LDPC(g,msg_en_clair)

[m,n]=size(g);         %nous on veut faire des paquets de 3 dans 1er example
N=length(msg_en_clair);
nb_paquet=N/m;

msg_bien=reshape(msg_en_clair,m,nb_paquet)'; %On mets le msg a envoye en paquet de 3 sur chaque ligne

msg_bien_encode=msg_bien*g; %on l'encode
msg_bien_encode=mod(msg_bien_encode,2); %en faisant attention au XOR

msg_bien_encode=msg_bien_encode'; %on le remet en ligne pour la modulation
msg_bien_encode=msg_bien_encode(:);
end

