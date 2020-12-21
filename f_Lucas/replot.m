clear all; close all; clc;

%% critère arrêt MIN-SUM/BP 10 itérations (mais n'en fait que 2)
figure(7)

TEB_TAB_MINSUM=[]
TEP_TAB_MINSUM=[]

load('critere_arret_BP_10it_fais_que_2.mat'); %BP 10 itérations

TEB_TAB_MINSUM=[TEB_TAB_MINSUM; ber];
TEP_TAB_MINSUM=[TEP_TAB_MINSUM; paquet_err];

load('critere_arret_MINSUM_10it_fais_que_2.mat'); %Min SUM 10 itérations

TEB_TAB_MINSUM=[TEB_TAB_MINSUM; ber];
TEP_TAB_MINSUM=[TEP_TAB_MINSUM; paquet_err];

semilogy(EbN0dB,TEB_TAB_MINSUM(1,:),'LineWidth',1);hold on;
semilogy(EbN0dB,TEB_TAB_MINSUM(2,:),'LineWidth',1);hold on;

semilogy(EbN0dB,TEP_TAB_MINSUM(1,:),'--','LineWidth',1);hold on;
semilogy(EbN0dB,TEP_TAB_MINSUM(2,:),'--','LineWidth',1);hold on;

xlim([0 10])
ylim([1e-6 1])
grid on
xlabel('$\frac{E_b}{N_0}$ en dB','Interpreter', 'latex', 'FontSize',14)
ylabel('TEB','Interpreter', 'latex', 'FontSize',14)
title("TEB et TEP pour BP et MIN-SUM pour 10 itérations avec critère d'arrêt");

legend("TEB BP 10 itération critère d'arrêt (6,3)","TEB MIN-SUM 10 itérations critère d'arrêt (6,3)","TEP BP 10 itération critère d'arrêt (6,3)","TEP MIN-SUM 10 itérations critère d'arrêt (6,3)")

%% MIN-SUM/BP 10 itérations
figure(6)

TEB_TAB_MINSUM=[]
TEP_TAB_MINSUM=[]

load('DEBUG_6_3_BP_10.mat'); %BP 10 itérations

TEB_TAB_MINSUM=[TEB_TAB_MINSUM; ber];
TEP_TAB_MINSUM=[TEP_TAB_MINSUM; paquet_err];

load('DEBUG_6_3_MIN_SUM_10.mat'); %Min SUM 10 itérations

TEB_TAB_MINSUM=[TEB_TAB_MINSUM; ber];
TEP_TAB_MINSUM=[TEP_TAB_MINSUM; paquet_err];

semilogy(EbN0dB,TEB_TAB_MINSUM(1,:),'LineWidth',1);hold on;
semilogy(EbN0dB,TEB_TAB_MINSUM(2,:),'LineWidth',1);hold on;

semilogy(EbN0dB,TEP_TAB_MINSUM(1,:),'--','LineWidth',1);hold on;
semilogy(EbN0dB,TEP_TAB_MINSUM(2,:),'--','LineWidth',1);hold on;

xlim([0 10])
ylim([1e-6 1])
grid on
xlabel('$\frac{E_b}{N_0}$ en dB','Interpreter', 'latex', 'FontSize',14)
ylabel('TEB','Interpreter', 'latex', 'FontSize',14)
title("TEB et TEP pour BP et MIN-SUM pour 10 itérations");

legend('TEB BP 10 itération (6,3)','TEB MIN-SUM 10 itérations (6,3)','TEP BP 10 itération (6,3)','TEP MIN-SUM 10 itérations (6,3)')


%% BP

TEB_TAB=[];
TEP_TAB=[];

load('DEBUG_6_31.mat'); %BP 1 itération

TEB_TAB=[TEB_TAB; ber];
TEP_TAB=[TEP_TAB; paquet_err];

load('DEBUG_6_32.mat'); %BP 2 itérations

TEB_TAB=[TEB_TAB; ber];
TEP_TAB=[TEP_TAB; paquet_err];

load('DEBUG_6_33.mat'); %BP 3 itérations

TEB_TAB=[TEB_TAB; ber];
TEP_TAB=[TEP_TAB; paquet_err];

load('DEBUG_6_34.mat'); %BP 4 itérations

TEB_TAB=[TEB_TAB; ber];
TEP_TAB=[TEP_TAB; paquet_err];

load('DEBUG_6_35.mat'); %BP 5 itérations

TEB_TAB=[TEB_TAB; ber];
TEP_TAB=[TEP_TAB; paquet_err];

figure(5)

semilogy(EbN0dB,TEB_TAB(1,:),'LineWidth',1);hold on;
semilogy(EbN0dB,TEB_TAB(2,:),'LineWidth',1);hold on;
semilogy(EbN0dB,TEB_TAB(3,:),'LineWidth',1);hold on;
semilogy(EbN0dB,TEB_TAB(4,:),'LineWidth',1);hold on;
semilogy(EbN0dB,TEB_TAB(5,:),'LineWidth',1);hold on;

semilogy(EbN0dB,TEP_TAB(1,:),'--','LineWidth',1);hold on;
semilogy(EbN0dB,TEP_TAB(2,:),'--','LineWidth',1);hold on;
semilogy(EbN0dB,TEP_TAB(3,:),'--','LineWidth',1);hold on;
semilogy(EbN0dB,TEP_TAB(4,:),'--','LineWidth',1);hold on;
semilogy(EbN0dB,TEP_TAB(5,:),'--','LineWidth',1);hold on;


xlim([0 10])
ylim([1e-6 1])
grid on
xlabel('$\frac{E_b}{N_0}$ en dB','Interpreter', 'latex', 'FontSize',14)
ylabel('TEB','Interpreter', 'latex', 'FontSize',14)
title("TEB et TEP par nombre d\'itération");

legend('TEB 1 itération','TEB 2 itérations','TEB 3 itérations','TEB 4 itérations','TEB 5 itérations','TEP 1 itération','TEP 2 itérations','TEP 3 itérations','TEP 4 itérations','TEP 5 itérations')
