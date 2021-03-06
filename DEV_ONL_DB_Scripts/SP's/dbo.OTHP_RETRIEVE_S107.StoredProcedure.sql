/****** Object:  StoredProcedure [dbo].[OTHP_RETRIEVE_S107]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OTHP_RETRIEVE_S107] (
 @Ac_TypeOthp_CODE  CHAR(1),
 @An_MemberMci_IDNO NUMERIC(10),
 @An_Case_IDNO      NUMERIC(6),
 @Ai_RowFrom_NUMB   INT = 1,
 @Ai_RowTo_NUMB     INT = 10
 )
AS
 /*
  *     PROCEDURE NAME    : OTHP_RETRIEVE_S107
  *     DESCRIPTION       : Retrieve the Other Party details for the given Member ID Number, Case ID Number and Type Other Party Code.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 17-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Lc_TypeOthpInsurers_CODE						CHAR(1) = 'I',
          @Lc_Yes_INDC									CHAR(1) = 'Y',
          @Lc_CaseMemberStatusActive_CODE				CHAR(1) = 'A',
          @Lc_TypeOthp2_CODE							CHAR(1) = '2',
          @Lc_TypeOthp3_CODE							CHAR(1) = '3',
          @Lc_TypeOthp4_CODE							CHAR(1) = '4',
          @Lc_TypeOthp5_CODE							CHAR(1) = '5',
          @Lc_TypeOthp6_CODE							CHAR(1) = '6',
          @Lc_TypeOthp7_CODE							CHAR(1) = '7',
          @Lc_TypeOthp9_CODE							CHAR(1) = '9',
          @Lc_TypeOthpD_CODE							CHAR(1) = 'D',
          @Lc_TypeOthpE_CODE							CHAR(1) = 'E',
          @Lc_TypeOthpG_CODE							CHAR(1) = 'G',
          @Lc_TypeOthpM_CODE							CHAR(1) = 'M',
          @Lc_TypeOthpU_CODE							CHAR(1) = 'U',
          @Lc_TypeOthpW_CODE							CHAR(1) = 'W',
          @Lc_TypeOthpX_CODE							CHAR(1) = 'X',
          @Lc_StatusPending_CODE						CHAR(1) = 'P',
          @Lc_TypeIncomeCs_CODE							CHAR(2) = 'CS',
          @Lc_TypeIncomeDs_CODE							CHAR(2) = 'DS',
          @Lc_TypeIncomeMb_CODE							CHAR(2) = 'MB',
          @Lc_TypeIncomeMl_CODE							CHAR(2) = 'ML',
          @Lc_TypeIncomeMr_CODE							CHAR(2) = 'MR',
          @Lc_TypeIncomePi_CODE							CHAR(2) = 'PI',
          @Lc_TypeIncomeRt_CODE							CHAR(2) = 'RT',
          @Lc_TypeIncomeSs_CODE							CHAR(2) = 'SS',
          @Lc_TypeIncomeUi_CODE							CHAR(2) = 'UI',
          @Lc_TypeIncomeUn_CODE							CHAR(2) = 'UN',
          @Lc_TypeIncomeVp_CODE							CHAR(2) = 'VP', 
          @Lc_TypeIncomeWc_CODE							CHAR(2) = 'WC',
          @Lc_TypeIncomeSe_CODE							CHAR(2) = 'SE',
          @Lc_TypeIncomeEmployer_CODE					CHAR(2) = 'EM',
          @Ld_High_DATE									DATE	= '12/31/9999';
  DECLARE @Ld_Current_DATE								DATE	= DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

  SELECT x.OtherParty_IDNO,
		 x.TypeOthp_CODE,
         x.OtherParty_NAME,
         x.Line1_ADDR,
         x.Line2_ADDR,
         x.City_ADDR,
         x.Zip_ADDR,
         x.State_ADDR,
         x.Fein_IDNO,
         x.MemberMci_IDNO,
         x.CaseRelationship_CODE,
         x.RowCount_NUMB
    FROM (SELECT o.OtherParty_IDNO,
				 o.TypeOthp_CODE,
                 o.OtherParty_NAME,
                 o.Line1_ADDR,
                 o.Line2_ADDR,
                 o.City_ADDR,
                 o.State_ADDR,
                 o.Zip_ADDR,
                 o.Fein_IDNO,
                 e.MemberMci_IDNO,
                 c.CaseRelationship_CODE,
                 ROW_NUMBER() OVER ( ORDER BY o.OtherParty_IDNO ) AS Row_NUMB,
                 COUNT(1) OVER() AS RowCount_NUMB
            FROM OTHP_Y1 o
             JOIN EHIS_Y1 e
              ON o.OtherParty_IDNO = e.OthpPartyEmpl_IDNO
             AND e.MemberMci_IDNO = @An_MemberMci_IDNO
             AND @Ld_Current_DATE BETWEEN e.BeginEmployment_DATE AND e.EndEmployment_DATE
             AND e.EndEmployment_DATE > @Ld_Current_DATE
             AND e.Status_CODE IN (@Lc_Yes_INDC,@Lc_StatusPending_CODE)
             JOIN CMEM_Y1 c
			  ON c.Case_IDNO = @An_Case_IDNO
             AND c.MemberMci_IDNO = e.MemberMci_IDNO
             AND c.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
           WHERE o.EndValidity_DATE = @Ld_High_DATE
             AND e.TypeIncome_CODE IN ((CASE @Ac_TypeOthp_CODE
                                         WHEN @Lc_TypeOthpE_CODE
                                          THEN @Lc_TypeIncomeEmployer_CODE
                                         WHEN @Lc_TypeOthpInsurers_CODE
                                          THEN @Lc_TypeIncomeCs_CODE
                                         WHEN @Lc_TypeOthpW_CODE
                                          THEN @Lc_TypeIncomeWc_CODE
                                         WHEN @Lc_TypeOthpM_CODE
                                          THEN @Lc_TypeIncomeMl_CODE
                                         WHEN @Lc_TypeOthp9_CODE
                                          THEN @Lc_TypeIncomeSs_CODE
                                         WHEN @Lc_TypeOthpU_CODE
                                          THEN @Lc_TypeIncomeUn_CODE
                                         WHEN @Lc_TypeOthp2_CODE
                                          THEN @Lc_TypeIncomeDs_CODE
                                         WHEN @Lc_TypeOthp3_CODE
                                          THEN @Lc_TypeIncomeMb_CODE
                                         WHEN @Lc_TypeOthp4_CODE
                                          THEN @Lc_TypeIncomePi_CODE
                                         WHEN @Lc_TypeOthp5_CODE
                                          THEN @Lc_TypeIncomeRt_CODE
                                         WHEN @Lc_TypeOthp6_CODE
                                          THEN @Lc_TypeIncomeSe_CODE  
                                         WHEN @Lc_TypeOthpX_CODE
                                          THEN @Lc_TypeIncomeUi_CODE
                                         WHEN @Lc_TypeOthp7_CODE
                                          THEN @Lc_TypeIncomeVp_CODE
                                         WHEN @Lc_TypeOthpG_CODE
                                          THEN @Lc_TypeIncomeRt_CODE
                                        END), (CASE @Ac_TypeOthp_CODE
                                                WHEN @Lc_TypeOthpG_CODE
                                                 THEN @Lc_TypeIncomeVp_CODE
                                                WHEN @Lc_TypeOthpM_CODE
                                                 THEN @Lc_TypeIncomeMr_CODE
                                               END))
             AND o.TypeOthp_CODE = CASE @Ac_TypeOthp_CODE
                                    WHEN @Lc_TypeOthp2_CODE
                                     THEN @Lc_TypeOthpX_CODE
                                    WHEN @Lc_TypeOthp3_CODE
                                     THEN @Lc_TypeOthpM_CODE
									WHEN @Lc_TypeOthp4_CODE
                                     THEN @Lc_TypeOthpM_CODE
                                    WHEN @Lc_TypeOthp5_CODE
                                     THEN @Lc_TypeOthpG_CODE
                                    WHEN @Lc_TypeOthp6_CODE
                                     THEN @Lc_TypeOthpE_CODE
                                    WHEN @Lc_TypeOthp7_CODE
                                     THEN @Lc_TypeOthpG_CODE 
                                    ELSE @Ac_TypeOthp_CODE
                                   END) AS x
   WHERE x.Row_NUMB BETWEEN @Ai_RowFrom_NUMB AND @Ai_RowTo_NUMB;
 END; --END OF OTHP_RETRIEVE_S107


GO
