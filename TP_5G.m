clear all; close all; clc;

%% INIT 

simulation=2;

nb_it= 5; % 1 iteration = v_toc + c_to_v
iterations=1;

bruit=0;
voir=1;

if simulation==1
    [H] = alist2sparse('alist/DEBUG_6_3.alist');
elseif simulation==2
    [H] = alist2sparse('alist/CCSDS_64_128.alist');
else
    [H] = alist2sparse('alist/MACKAY_504_1008.alist');
end

[h, g] = ldpc_h2g(H); % g = matrice genereatrice
H_full = full(H);
[m, n] = size(H_full);

msg_envoye= randi([0 1],1,m);
%% Travail 1

%H n'est pas régulière car:
% r = nombre de 1 par ligne non constant
% g = nombre de 1 par colonne non constant

%Polynome des degrés cahier

disp=0;
if disp == 1
    tg = tanner_graph(H_full); % Building the Tanner graph
    plot(tg) % Display the Tanner graph
    title('Graphe de Tanner associé à H');
end
% tg.to_tikz('hamming.tex'); % Export to Tikz COMPILER LATEX

%% Travail 2 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 1st COM Pour voir faire un décodeur qui fonctionne %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

M = 4; % Modulation BPSK <=> 2 symboles 0 ou 1
phi0 = 0; % Offset de phase our la BPSK

mod_psk = comm.PSKModulator(...
    'ModulationOrder', M, ... % BPSK
    'PhaseOffset'    , phi0, ...
    'SymbolMapping'  , 'Gray',...
    'BitInput'       , true);

demod_psk = comm.PSKDemodulator(...
    'ModulationOrder', M      , ...
    'PhaseOffset'    , phi0   , ...
    'SymbolMapping'  , 'Gray' , ...
    'BitOutput'      , true   , ...
    'DecisionMethod' , 'Log-likelihood ratio');

R = 1; % Rendement de la communication
R = (n-gfrank(H_full))/n;
EbN0dB_min  = -2; % Minimum de EbN0
EbN0dB_max  = 10; % Maximum de EbN0
EbN0dB_step = 1;% Pas de EbN0

EbN0dB = EbN0dB_min:EbN0dB_step:EbN0dB_max;     % Points de EbN0 en dB à simuler
EbN0   = 10.^(EbN0dB/10);% Points de EbN0 à simuler
EsN0   = R*log2(M)*EbN0; % Points de EsN0
EsN0dB = 10*log10(EsN0); % Points de EsN0 en dB à simuler

awgn_channel = comm.AWGNChannel(...
    'NoiseMethod', 'Signal to noise ratio (Es/No)',...
    'EsNo',EsN0dB(1),...
    'SignalPower',1);

%% encode
u1 = [1 1 1];
u2 = [0 0 0];
u3 = [1 0 1];
k=3;
n=6;


% msg_envoye = [1;1;0;1;1;1];

encode_fonction=1;
if encode_fonction==0
    c1=msg_envoye*g;
    c1=mod(c1,2); %xor => 1+1 = 0 ; 1+0=1 => msg en clair sur 3 derniers bits
    %verif mod(c1 * H_full',2)
    msg_code=c1';
end

[msg_code] = encode_LDPC(g,msg_envoye);

msg_code_mod = step(mod_psk,msg_code);      % Modulation QPSK

%% canal

if bruit==0
    y=msg_code_mod; %canal sans bruit pour test
else
    y=step(awgn_channel,msg_code_mod);
end

%% Decode

Lc = step(demod_psk, y); %là t'as des LLR/observations du canal que faut décoder
canal_obs = Lc;
%ce truc faut le faire passer dans le décodeur
%avec la matrice de parité tout ça 

[msg_decode, res_final]=decodage_LDPC(H,canal_obs,nb_it); %last input = nb_iterations

if voir==1

msg_envoye=msg_envoye'
res_final
msg_decode
diff_entre_msg_envoye_msg_recu = find(msg_envoye~=msg_decode);
nb_differences=length(diff_entre_msg_envoye_msg_recu)
end
msg_recu_egal_msg_envoye=isequal(msg_envoye,msg_decode)*1








%%% TEST POUR CREER LA FONCTION DE DECODAGE %%%% c'est OK on va plus là dedans
juste_fonctions=1;


if juste_fonctions==0
    
    
    
    
    
%% TESTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% INDICES des noeuds C_k CONNECTES à un V CHOISIT
C_2_V0 = C_2_Vk(H_full,0); %On regarde quels noeuds C_k sont connectés à V0
C_2_V1 = C_2_Vk(H_full,1);
C_2_V2 = C_2_Vk(H_full,2);
C_2_V3 = C_2_Vk(H_full,3);
C_2_V4 = C_2_Vk(H_full,4);
C_2_V5 = C_2_Vk(H_full,5);

% INDICES des noeuds V_k CONNECTES à un C CHOISIT
V_2_C0 = V_2_Ck(H_full, 0); %On regarde quels noeuds V_k sont connectés à C0
V_2_C1 = V_2_Ck(H_full, 1);
V_2_C2 = V_2_Ck(H_full, 2);
nb_aretes=length(V_2_C0)+length(V_2_C1)+length(V_2_C2);
% LLR (formules p.45)

%stock les LLR des v vers les c
v_to_c = zeros(3,6); %valeur des messages noeuds de variable vers noeuds de parité

%stock les LLR des c vers les v
c_to_v = v_to_c;     %valeur des messages noeuds de parité vers noeuds de variable


% UPDATES CTOV ET VTOC
v_to_c = [ 1 2 3 4 5 6; 8 9 10 11 12 13; 15 16 17 18 19 20];
c_to_v = [ 15 16 17 18 19 20 ; 1 2 3 4 5 6; 8 9 10 11 12 13];

[v_to_c] = update_v_to_c(v_to_c, 27, 3, 1);
[c_to_v] = update_c_to_v(c_to_v, 27, 3, 1);


%%%   TEST L_c_to_v    %%%%   !!! OK !!!! PARITE => VAR 2*atanh( tanh(LLR/2)) OK

% [res_L_c_to_v] = L_c_to_v(H_full, v_to_c, 0,0) %Test L_c_to_v de c0 versv0 => OK
% c0 que connecté à v2=3 => res_L_c_to_v = 2*atanh( tanh(3/2) ) = 3.000

% [res_L_c_to_v] = L_c_to_v(H_full, v_to_c, 1,1) %Test L_c_to_v de c1 versv1 => OK
% v1_c1=9 prend pas et v3_c1=11 et v4_c1=12 => res_L_c_to_v = 2 *atanh( tanh(11/2)*tanh(12/2) ) = 10.6867

% [res_L_c_to_v] = L_c_to_v(H_full, v_to_c, 2,5) %Test L_c_to_v de c2 vers v5 => OK
% v5_c2=20 prend pas et v3_c2=11 et v2_c2=12 => res_L_c_to_v = 2 *atanh( tanh(17/2)*tanh(18/2) ) = 16.6867

% [res_L_c_to_v] = L_c_to_v(H_full, v_to_c, 0,2) %Test L_c_to_v de c0 vers v2 => OK
% v2_c0=3 prend pas et v0_c0=1  => res_L_c_to_v = 2 *atanh( tanh(1/2) ) = 1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%   TEST L_v_to_c   %%%%   !!! OK !!!!  VAR => PARITE sum(LLR) OK

% [res_L_v_to_c] = L_v_to_c(1,H_full, c_to_v, 0,0) %Test L_v_to_c de v0 versc0
% pas de c lié à v0 => res_L_v0_to_c0 = v0 = canal_obs = 1=1

% [res_L_v_to_c] = L_v_to_c(1,H_full, c_to_v, 2,2) %Test L_v_to_c de v2 versc2
% c0 lié à v2 => res_L_v0_to_c0 = c0 + v2 + canal_obs = 17+1=18

% [res_L_v_to_c] = L_v_to_c(1,H_full, c_to_v, 5,2) %Test L_v_to_c de v5 versc2
% pas de c lié à v5 => res_L_v0_to_c0 = v5 = canal_obs = 1 

% [res_L_v_to_c] = L_v_to_c(1,H_full, c_to_v, 3,1) %Test L_v_to_c de v3 versc1
% c2 lié à v3 => res_L_v3_to_c1 = 11 + canal_obs = 11+1=12

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
v_to_c = zeros(3,6); % INIT = LLR c_to_v=0
c_to_v = zeros(3,6); % INIT = LLR c_to_v=0

% 1ère iteration: observations du canal vers noeurds de variables

%En recevant observatio du canal on mets à jour les LLRs des v vers les c
%(c vers v vide)
[v_to_c] = update_v_to_c(v_to_c, canal_obs(1), 0, 0); %observation du canal du noeud de variable 0 vas vers le noeuds de parité 0
[v_to_c] = update_v_to_c(v_to_c, canal_obs(2), 1, 1); %observation du canal du noeud de variable 1 vas vers le noeuds de parité 1
[v_to_c] = update_v_to_c(v_to_c, canal_obs(3), 2, 0); %observation du canal du noeud de variable 2 vas vers le noeuds de parité 0
[v_to_c] = update_v_to_c(v_to_c, canal_obs(3), 2, 2); %observation du canal du noeud de variable 2 vas vers le noeuds de parité 2
[v_to_c] = update_v_to_c(v_to_c, canal_obs(4), 3, 1); %observation du canal du noeud de variable 3 vas vers le noeuds de parité 1
[v_to_c] = update_v_to_c(v_to_c, canal_obs(4), 3, 2); %observation du canal du noeud de variable 3 vas vers le noeuds de parité 2
[v_to_c] = update_v_to_c(v_to_c, canal_obs(5), 4, 1); %observation du canal du noeud de variable 4 vas vers le noeuds de parité 2
[v_to_c] = update_v_to_c(v_to_c, canal_obs(6), 5, 2); %observation du canal du noeud de variable 5 vas vers le noeuds de parité 2

%On calcul ce qu'on reçoit sur les c et qu'on renvoie vers les V 1ère iteration
%L_c_to_v(H_full, v_to_c, indice_C,indice_V_final)
% + mise à jour des v
%[c_to_v] = update_c_to_v(c_to_v, res_L_c_to_v, indice_c, indice_v_final)

[res_L_c_to_v] = L_c_to_v(H_full, v_to_c, 0,0); %Co (reçoit v0 et v2 mais renvoie juste le v2) to V0
[c_to_v] = update_c_to_v(c_to_v, res_L_c_to_v, 0,0);

[res_L_c_to_v] = L_c_to_v(H_full, v_to_c, 0,2); %Co (reçoit v0 et v2 mais renvoie juste le v0) to V2
[c_to_v] = update_c_to_v(c_to_v, res_L_c_to_v, 0,2);

[res_L_c_to_v] = L_c_to_v(H_full, v_to_c, 1,1); %C1 to V1
[c_to_v] = update_c_to_v(c_to_v, res_L_c_to_v, 1,1);
[res_L_c_to_v] = L_c_to_v(H_full, v_to_c, 1,3); %C1 to V3
[c_to_v] = update_c_to_v(c_to_v, res_L_c_to_v, 1,3);
[res_L_c_to_v] = L_c_to_v(H_full, v_to_c, 1,4); %C1 to V4
[c_to_v] = update_c_to_v(c_to_v, res_L_c_to_v, 1,4);

[res_L_c_to_v] = L_c_to_v(H_full, v_to_c, 2,2); %C2 to V2
[c_to_v] = update_c_to_v(c_to_v, res_L_c_to_v, 2,2);
[res_L_c_to_v] = L_c_to_v(H_full, v_to_c, 2,3); %C2 to V3
[c_to_v] = update_c_to_v(c_to_v, res_L_c_to_v, 2,3);
[res_L_c_to_v] = L_c_to_v(H_full, v_to_c, 2,5); %C2 to V5
[c_to_v] = update_c_to_v(c_to_v, res_L_c_to_v, 2,5);

%On s'arrête et on regarde les valeurs finales sur les noeuds de variables
%V, en sommant juste ce qu'on reçoit des noeuds de parités C + observation
%du canal
res=sum(c_to_v')'+canal_obs %ligne magique de fin
% on voit bien que la valeurs des V a changé après une itération en
% creusant l'écart pour la décision, yes!

%On mets a jour les V
[v_to_c] = update_v_to_c(v_to_c, res(1), 0, 0); 
[v_to_c] = update_v_to_c(v_to_c, res(2), 1, 1); 
[v_to_c] = update_v_to_c(v_to_c, res(3), 2, 0); 
[v_to_c] = update_v_to_c(v_to_c, res(3), 2, 2); 
[v_to_c] = update_v_to_c(v_to_c, res(4), 3, 1); 
[v_to_c] = update_v_to_c(v_to_c, res(4), 3, 2); 
[v_to_c] = update_v_to_c(v_to_c, res(5), 4, 1); 
[v_to_c] = update_v_to_c(v_to_c, res(6), 5, 2);

%Dans le cas où on fait d'autres iteration pour test
if iterations ==1

    for i = 2:nb_iterations_tot
        %On calcul ce que l'on a sur les V après la au début de l'itération
        %Car on va renvoyer de l'info aux C (observatio canal + ce qu'on reçoit apres une iteration)
%         [res_L_v_to_c] = L_v_to_c( canal_obs(1), H_full, c_to_v, 0,0) %V0 to C0
%         [v_to_c] = update_v_to_c(v_to_c, canal_obs(1), 0, 0)
% 
% 
%         [res_L_v_to_c] = L_v_to_c( canal_obs(2), H_full, c_to_v, 1,1) %V1 to C1
%         [v_to_c] = update_v_to_c(v_to_c, canal_obs(2), 1, 1)
% 
%         [res_L_v_to_c] = L_v_to_c( canal_obs(3), H_full, c_to_v, 2,0) %V2 to C0
%         [v_to_c] = update_v_to_c(v_to_c, canal_obs(3), 2, 0)
%         [res_L_v_to_c] = L_v_to_c( canal_obs(3), H_full, c_to_v, 2,2) %V2 to C2
%         [v_to_c] = update_v_to_c(v_to_c, canal_obs(3), 2, 2)
% 
% 
%         [res_L_v_to_c] = L_v_to_c( canal_obs(4), H_full, c_to_v, 3,1) %V3 to C1
%         [v_to_c] = update_v_to_c(v_to_c, canal_obs(4), 3, 1)
%         [res_L_v_to_c] = L_v_to_c( canal_obs(4), H_full, c_to_v, 3,2) %V3 to C2
%         [v_to_c] = update_v_to_c(v_to_c, canal_obs(4), 3, 2)
% 
% 
%         [res_L_v_to_c] = L_v_to_c( canal_obs(5), H_full, c_to_v, 4,1) %V4 to C1
%         [v_to_c] = update_v_to_c(v_to_c, canal_obs(5), 4, 1)
%         [res_L_v_to_c] = L_v_to_c( canal_obs(5), H_full, c_to_v, 4,1) %V4 to C1   
%         [v_to_c] = update_v_to_c(v_to_c, canal_obs(5), 4, 1)

        %et on fait exactement le même premier process et ça doit marcher
        [res_L_c_to_v] = L_c_to_v(H_full, v_to_c, 0,0) %Co (reçoit v0 et v2 mais renvoie juste le v2) to V0
        [c_to_v] = update_c_to_v(c_to_v, res_L_c_to_v, 0,0)

        [res_L_c_to_v] = L_c_to_v(H_full, v_to_c, 0,2) %Co (reçoit v0 et v2 mais renvoie juste le v0) to V2
        [c_to_v] = update_c_to_v(c_to_v, res_L_c_to_v, 0,2)

        [res_L_c_to_v] = L_c_to_v(H_full, v_to_c, 1,1) %C1 to V1
        [c_to_v] = update_c_to_v(c_to_v, res_L_c_to_v, 1,1)
        [res_L_c_to_v] = L_c_to_v(H_full, v_to_c, 1,3) %C1 to V3
        [c_to_v] = update_c_to_v(c_to_v, res_L_c_to_v, 1,3)
        [res_L_c_to_v] = L_c_to_v(H_full, v_to_c, 1,4) %C1 to V4
        [c_to_v] = update_c_to_v(c_to_v, res_L_c_to_v, 1,4)

        [res_L_c_to_v] = L_c_to_v(H_full, v_to_c, 2,2) %C2 to V2
        [c_to_v] = update_c_to_v(c_to_v, res_L_c_to_v, 2,2)
        [res_L_c_to_v] = L_c_to_v(H_full, v_to_c, 2,3) %C2 to V3
        [c_to_v] = update_c_to_v(c_to_v, res_L_c_to_v, 2,3)
        [res_L_c_to_v] = L_c_to_v(H_full, v_to_c, 2,5) %C2 to V5
        [c_to_v] = update_c_to_v(c_to_v, res_L_c_to_v, 2,5)
        
        res=sum(c_to_v')'+canal_obs %ligne magique de fin
        % on voit bien que la valeurs des V a changé après une itération en
        % creusant l'écart pour la décision, yes!

        [v_to_c] = update_v_to_c(v_to_c, res(1), 0, 0); %observation du canal du noeud de variable 0 vas vers le noeuds de parité 0
        [v_to_c] = update_v_to_c(v_to_c, res(2), 1, 1); %observation du canal du noeud de variable 1 vas vers le noeuds de parité 1
        [v_to_c] = update_v_to_c(v_to_c, res(3), 2, 0); %observation du canal du noeud de variable 2 vas vers le noeuds de parité 0
        [v_to_c] = update_v_to_c(v_to_c, res(3), 2, 2); %observation du canal du noeud de variable 2 vas vers le noeuds de parité 2
        [v_to_c] = update_v_to_c(v_to_c, res(4), 3, 1); %observation du canal du noeud de variable 3 vas vers le noeuds de parité 1
        [v_to_c] = update_v_to_c(v_to_c, res(4), 3, 2); %observation du canal du noeud de variable 3 vas vers le noeuds de parité 2
        [v_to_c] = update_v_to_c(v_to_c, res(5), 4, 1); %observation du canal du noeud de variable 4 vas vers le noeuds de parité 2
        [v_to_c] = update_v_to_c(v_to_c, res(6), 5, 2);

    end

end


test_parite=(res'<0)*1
res=res';

bruit
iterations
nb_iterations_tot

res_final = res(n-k+1:n) %On prend seulement les 3 derniers bits car Id dans matrice génératrice est sur les 3 derniers bits
msg_decod=(res_final<0);
msg_decod=msg_decod*1; %passe vecteur non logical

% verification = mod(mot_de_code * H_full',2) %verif si c'est un bien un mot de code
parite=mod(test_parite * H_full',2); %verifie si le mot decodé est bien un mot de code
verif_decodage=0;
if sum(parite)==0 %si full 0 => OK
    verif_decodage=1;
end

msg_envoye
msg_recu=msg_decod
verif_decodage % a ne pas regarde si on mets du bruit
end


%% Res sans bruit => NORMALEMENT DECODAGE OK
% u1=[1 1 1] / c1=[0 0 0 1 1 1] / y=c1 / Lc=[4 4 4 -4 -4 -4] / 
%res + Lc = [8 8 8 -12 -8 -8]   
%res_final = [-12 -8 -8] => full negatif => decodage = [1 1 1]

% u2=[0 0 0] / c2=[0 0 0 0 0 0] / y=c2 / Lc=[4 4 4 4 4 4] / 
%res = [8 8 8 12 8 8]   
%res_final = [12 8 8] => full positif => decodage [0 0 0]

% u3=[1 0 1] / c3=[0 1 0 1 0 1] / y=c3 / Lc=[8 -8 8 -8 8 -8] / 
%res = [8 -8 8 -12 8 -8] 
%res_final = [-12 8 -8] => full positif => decodage [1 0 1]

%% ON generalise pour pas faire ça "à la main" en appelant 14 fois les fonctions


%Normalement si je fais + de tour de decodage ça doit converger vers + ou -
%l'infini j'imagine

% attend voir si j'ai bien compris:
% 1)
% - au début tu veux envoyer un msg de 3 bits disons: u1=[ 1 1 1]
% - du coup tu l'encode avec la matrice génératrice en faisant x = u1*g
% - moi ça me donne [2 2 2 1 1 1]
% - ensuite faut le moduler donc des 1 et des 0 du coup j'ai fais x=x-1 (c'est peut être trop une schnapserie)
% - puis tu le module msg_code_mod = step(mod_psk,msg_code)
% 
% 2) tu l'envoie dans le canal mais tu crie pas dedans pour commencer
% y=msg_code_mod;
% 
% 3) et ensuite tu récupère une observation du canal que tu vas balancer sur chaque v0...v5 
% Lc = step(demod_psk, y) %là t'as des LLR/observations du canal que faut décoder
% canal_obs = Lc;
% 
% 4) faut faire un aller retour dans le graph pour décoder ? jme rappel plus,
% la je viens d'envoyer les v sur les c puis de les renvoyer sur les v

%1ere iteration, seule observation le canal, autres iterations aussi les
%autres noeuds
% matrice encodage systematique
%etraire vecteur u uniquement ce qui correspond a ton msg





