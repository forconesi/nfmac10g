// Marco Forconesi

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include "pcap.h"

/* prints wire declaration for din */
#define pr_hdr_din(f) fprintf(f, "wire [74:0] din[0:DATA_SIZE-1] = {\n"); \
                    fprintf(f, "/* {tdata, tkeep, tuser[0:0], tlast, tvalid} */\n");

/* prints a comment with the pkt number that starts */
#define pr_pkt_hdr_din(f, n) fprintf(f, "/* STARTS PKT\t%03d */\n", n+1);

/* prints a comment with the pkt number that ends */
#define pr_pkt_foot_din(f, n, b, chp) if (!chp) {fprintf(f, "/* ENDS PKT\t%03d\tBYTES:\t%03d */\n", n+1, b);} \
                                else if (chp == 1) {fprintf(f, "/* Discontinued PKT ENDS\t%03d */\n", n+1);} \
                                else {fprintf(f, "/* CHOPPED PKT ENDS\t%03d */\n", n+1);}

/* detects last axi transaction from pkt_len and current_index */
#define is_tlast(len, i) ((len == i) ? 1 : 0)

/* prints din transaction */
#define pr_din_trn(f, dh, dl, k, u, l, v, trn)   if (trn > 0) fprintf(f, ","); \
                                fprintf(f, "{64'h%08x%08x, ", dh, dl); \
                                fprintf(f, "8'h%02x, ", k); \
                                fprintf(f, "1'b%x, 1'b%x, 1'b%x}\n", u, l, v);

#define pr_close_arr(f) fprintf(f, "};\n");

#define pr_parm(f, trn, pkts) fprintf(f, "localparam DATA_SIZE = %d;\n", trn); \
                    fprintf(f, "localparam PKT_COUNT  = %d;\n", pkts);

/* prints wire declaration for corrupt_pkt */
#define pr_hdr_corr(f) fprintf(f, "wire corrupt_pkt[0:PKT_COUNT-1] = {\n");

/* prints corrupt_pkt val */
#define pr_corr_v(f, v, trn)   if (trn > 0) fprintf(f, ","); \
                                fprintf(f, "1'b%x\n", v);

/* prints 1 if packet should be corrupted */
void
pr_corr(
    FILE *fp,
    int pkt_cnt,
    u_char flag
    ) {

    int i;

    pr_hdr_corr(fp);
    for (i = 0; i < pkt_cnt; i++) {

        if (flag == 2) {
            pr_corr_v(fp, 1, i);
        }
        else if (flag == 1) {
            pr_corr_v(fp, i % 2, i);            
        }
        else {
            pr_corr_v(fp, 0, i);
        }
    }
    pr_close_arr(fp);
}

int
main(
    int argc,
    char *argv[]
    ) {

    /* pcap var */
    pcap_t *pcap_dscr;
    char errbuf[PCAP_ERRBUF_SIZE];
    const u_char *pkt;
    struct pcap_pkthdr pkt_hdr;

    /* output files */
    FILE *din_fp, *parm_fp, *corr_fp;

    int i, j, k, z, trn_cnt, pkt_trn_cnt;
    uint64_t tdata;
    u_char octect, chopped_pkt;
    u_char tlast, tvalid, tkeep, tuser;
    // Params
    int ifg, corr_levl, underrun;

    if (argc < 5) {
        printf("usage: %s <pcap_file> <IFG> <CORR_LEVL> <UNDERRUN>\n", argv[0]);
        return -1;
    }

    /* Open PCAP file */
    pcap_dscr = pcap_open_offline(argv[1], errbuf);
    if (pcap_dscr == NULL) {
        printf("Failed pcap_open\n");
        return -1;
    }

    /* Inteframe Gap */
    ifg = atoi(argv[2]);

    /* Corrupt pkts level */
    corr_levl = atoi(argv[3]);

    /* Tx underrun */
    underrun = atoi(argv[4]);

    /* Open output files */
    din_fp = fopen("sim_stim.dat", "w");
    parm_fp = fopen("localparam.dat", "w");
    corr_fp = fopen("corr_pkt.dat", "w");
    if (din_fp == NULL || parm_fp == NULL || corr_fp == NULL) {
        pcap_close(pcap_dscr);
        fclose(din_fp);
        fclose(parm_fp);
        fclose(corr_fp);
        printf("Failed to open output files\n");
        return -1;
    }

    trn_cnt = 0;
    pr_hdr_din(din_fp);

    for (z = 0; ; z++) {
        pkt = pcap_next(pcap_dscr, &pkt_hdr);
        if (pkt == NULL) {
            pr_close_arr(din_fp);
            fclose(din_fp);
            pr_parm(parm_fp, trn_cnt, z);
            fclose(parm_fp);
            pcap_close(pcap_dscr);
            pr_corr(corr_fp, z, corr_levl);
            fclose(corr_fp);
            return 0;
        }

        pr_pkt_hdr_din(din_fp, z);

        i = 0;
        pkt_trn_cnt = 0;
        tvalid = 1;
        chopped_pkt = 0;
        while (i < pkt_hdr.len) {
            tdata = 0;
            tkeep = 0;
            tuser = 0;
            for (k = 0; k < 8 ; k++) {
                octect = *(pkt + i);
                tdata |= ((uint64_t)octect << (k*8));
                tkeep |= 1 << k;
                i++;
                if (i == pkt_hdr.len) {
                    break;
                }
                else if ((underrun == 1) && (!chopped_pkt)) { // Explicit underrun
                    if ((pkt_trn_cnt > 2) && (z % 3)) { // the packet must have the header fields (see ug)
                        tuser = 1;
                        chopped_pkt = 1;
                    }
                }
                else if (underrun == 2) { // Implicit underrun
                    if ((pkt_trn_cnt > 3) && (z % 3)) { // the packet must have the header fields (see ug)
                        tvalid = 0;
                        chopped_pkt = 2;
                        i = pkt_hdr.len; // exit loop
                    }
                }
            }
            tlast = is_tlast(pkt_hdr.len, i);
            pr_din_trn(din_fp, (uint32_t)(tdata >> 32), 
                (uint32_t)(tdata), tkeep, tuser, tlast, tvalid, trn_cnt);
            trn_cnt++;
            pkt_trn_cnt++;
        }

        pr_pkt_foot_din(din_fp, z, i, chopped_pkt);

        /* Inteframe Gap */
        for (j = 0; j < ((ifg*z) % 17); j++) {
            pr_din_trn(din_fp, 0, 0, 0, 0, 0, 0, trn_cnt);
            trn_cnt++;
        }

    }

}
