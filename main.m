%clear
clc

%% Parametres
% -------------------------------------------------------------------------
%k = nb bit dans un msg
%M = 2^k = nombre de message possible
%n = longueur du msg encodé

addpath('src')

nb_iterations_LDPC=5;

%FORT SNR, sigma2 très petit, regarder les NaN = corriger
simulation_test=1

voir=0; 

if simulation_test==1
    simulation_test
    [H] = alist2sparse('alist/DEBUG_6_3.alist');
    simulation_name = 'DEBUG_6_3';
    bit_par_pqt   = 330;% Nombre de bits par paquet

elseif simulation_test==2
    simulation_test
    [H] = alist2sparse('alist/CCSDS_64_128.alist');
    simulation_name = 'CCSDS_64_128';
    bit_par_pqt   = 128;
else
    [H] = alist2sparse('alist/MACKAY_504_1008.alist');
    simulation_test
    simulation_name = 'MACKAY_504_1008';
    bit_par_pqt   = 55440;
end

[h, g] = ldpc_h2g(H); % g = matrice genereatrice

H_full = full(H);
[m, n] = size(H_full);
% R = 1; % Rendement de la communication
R=(n-gfrank(H_full))/n;
bit_par_pqt=m;
pqt_par_trame = 1; % Nombre de paquets par trame
K = pqt_par_trame*bit_par_pqt; % Nombre de bits de message par trame
N = K/R; % Nombre de bits codés par trame (codée)

M = 2; % Modulation BPSK <=> 2 symboles
phi0 = 0; % Offset de phase our la BPSK

EbN0dB_min  = -2; % Minimum de EbN0
EbN0dB_max  = 10; % Maximum de EbN0
EbN0dB_step = 1;% Pas de EbN0

nbr_erreur  = 100;  % Nombre d'erreurs à observer avant de calculer un BER
nbr_bit_max = 100e6;% Nombre de bits max à simuler
ber_min     = 1e-6; % BER min

EbN0dB = EbN0dB_min:EbN0dB_step:EbN0dB_max;     % Points de EbN0 en dB à simuler
EbN0   = 10.^(EbN0dB/10);% Points de EbN0 à simuler
EsN0   = R*log2(M)*EbN0; % Points de EsN0
EsN0dB = 10*log10(EsN0); % Points de EsN0 en dB à simuler

% -------------------------------------------------------------------------

%% Construction du modulateur
mod_psk = comm.PSKModulator(...
    'ModulationOrder', M, ... % BPSK
    'PhaseOffset'    , phi0, ...
    'SymbolMapping'  , 'Gray',...
    'BitInput'       , true);

%% Construction du demodulateur
demod_psk = comm.PSKDemodulator(...
    'ModulationOrder', M, ...
    'PhaseOffset'    , phi0, ...
    'SymbolMapping'  , 'Gray',...
    'BitOutput'      , true,...
    'DecisionMethod' , 'Log-likelihood ratio');

%% Construction du canal AWGN
awgn_channel = comm.AWGNChannel(...
    'NoiseMethod', 'Signal to noise ratio (Es/No)',...
    'EsNo',EsN0dB(1),...
    'SignalPower',1);

%% Construction de l'objet évaluant le TEB
stat_erreur = comm.ErrorRate(); % Calcul du nombre d'erreur et du BER

%% Initialisation des vecteurs de résultats
ber = zeros(1,length(EbN0dB));
Pe = qfunc(sqrt(2*EbN0));
paquet_err = zeros(1,length(EbN0dB));

%% Préparation de l'affichage
figure(1)
h_ber = semilogy(EbN0dB,ber,'XDataSource','EbN0dB', 'YDataSource','ber');
% h_per = semilogy(EbN0dB,paquet_err,'XDataSource','EbN0dB', 'YDataSource','per');
hold all
ylim([1e-6 1])
grid on
xlabel('$\frac{E_b}{N_0}$ en dB','Interpreter', 'latex', 'FontSize',14)
ylabel('TEB','Interpreter', 'latex', 'FontSize',14)

%% Préparation de l'affichage en console
msg_format = '|   %7.2f  |   %9d   |  %9d | %2.2e |  %8.2f kO/s |   %8.2f kO/s |   %8.2f s |\n';

fprintf(      '|------------|---------------|------------|----------|----------------|-----------------|--------------|\n')
msg_header =  '|  Eb/N0 dB  |    Bit nbr    |  Bit err   |   TEB    |    Debit Tx    |     Debit Rx    | Tps restant  |\n';
fprintf(msg_header);
fprintf(      '|------------|---------------|------------|----------|----------------|-----------------|--------------|\n')


%% Simulation
for i_snr = 1:length(EbN0dB)
    reverseStr = ''; % Pour affichage en console
    awgn_channel.EsNo = EsN0dB(i_snr);% Mise a jour du EbN0 pour le canal
    
    stat_erreur.reset; % reset du compteur d'erreur
    err_stat    = [0 0 0]; % vecteur résultat de stat_erreur
    
    erreur_dans_paquet = 0;
    taux_erreur_paquets = 0;
    
    demod_psk.Variance = awgn_channel.Variance;
    
    n_frame = 0;
    T_rx = 0;
    T_tx = 0;
    general_tic = tic;
    while (err_stat(2) < nbr_erreur && err_stat(3) < nbr_bit_max)
        n_frame = n_frame + 1;
        
        %% Emetteur
        tx_tic = tic;                 % Mesure du débit d'encodage
        b    = randi([0,1],K,1);    % Génération du message aléatoire
        [msg_encode] = encode_LDPC(g,b);

        x      = step(mod_psk,  msg_encode); % Modulation BPSK
        T_tx   = T_tx+toc(tx_tic);    % Mesure du débit d'encodage
        
        %% Canal
        y     = step(awgn_channel,x); % Ajout d'un bruit gaussien
%         y = x; %ON PEUT TEST 1st sans crier dans le canal
        % LLR AWGN channel https://fr.mathworks.com/help/comm/ug/digital-modulation.html#brc6yjx
        %% Recepteur
        rx_tic = tic;                  % Mesure du débit de décodage
        Lc      = step(demod_psk,y);   % Démodulation (retourne des LLRs)
        canal_obs=Lc';
%         rec_b = double(Lc(1:K) < 0);   % Décision JUSTE BPSK par default

        rec_b=decodage_LDPC(H,canal_obs,nb_iterations_LDPC);
        
        if voir==1
        msg_recu_egal_msg_envoye=isequal(b,rec_b)*1  %voir si msg_recu=msg_envoye SANS BRUIT
        diff_entre_msg_envoye_msg_recu = find(b~=rec_b);
        nb_differences=length(diff_entre_msg_envoye_msg_recu)
        end
        
        T_rx    = T_rx + toc(rx_tic);  % Mesure du débit de décodage
        
        err_stat   = step(stat_erreur, b, rec_b); % Comptage des erreurs binaires
        
        erreur_dans_paquet = erreur_dans_paquet + any(rec_b~=b);
        taux_erreur_paquets = erreur_dans_paquet /n_frame;
        
        %% Affichage du résultat
        if mod(n_frame,100) == 1
            msg = sprintf(msg_format,...
                EbN0dB(i_snr),         ... % EbN0 en dB
                err_stat(3),           ... % Nombre de bits envoyés
                err_stat(2),           ... % Nombre d'erreurs observées
                err_stat(1),           ... % BER
                err_stat(3)/8/T_tx/1e3,... % Débit d'encodage
                err_stat(3)/8/T_rx/1e3,... % Débit de décodage
                toc(general_tic)*(nbr_erreur - min(err_stat(2),nbr_erreur))/(min(err_stat(2),nbr_erreur))); % Temps restant
            fprintf(reverseStr);
            msg_sz =  fprintf(msg);
            reverseStr = repmat(sprintf('\b'), 1, msg_sz);
        end
        
    end
    
    msg = sprintf(msg_format,...
        EbN0dB(i_snr),         ... % EbN0 en dB
        err_stat(3),           ... % Nombre de bits envoyés
        err_stat(2),           ... % Nombre d'erreurs observées
        err_stat(1),           ... % BER
        err_stat(3)/8/T_tx/1e3,... % Débit d'encodage
        err_stat(3)/8/T_rx/1e3,... % Débit de décodage
        0); % Temps restant
    fprintf(reverseStr);
    msg_sz =  fprintf(msg);
    reverseStr = repmat(sprintf('\b'), 1, msg_sz);
    
    ber(i_snr) = err_stat(1);
    paquet_err(i_snr) = taux_erreur_paquets;
    refreshdata(h_ber);
    drawnow limitrate
    
    if err_stat(1) < ber_min
        break
    end
    
end
fprintf('|------------|---------------|------------|----------|----------------|-----------------|--------------|\n')

%%
figure(1)
semilogy(EbN0dB,ber);
semilogy(EbN0dB,paquet_err,'--');
hold all
xlim([0 10])
ylim([1e-6 1])
grid on
xlabel('$\frac{E_b}{N_0}$ en dB','Interpreter', 'latex', 'FontSize',14)
ylabel('TEB','Interpreter', 'latex', 'FontSize',14)

save(simulation_name,'EbN0dB','ber','paquet_err')
