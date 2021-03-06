/****** Object:  StoredProcedure [dbo].[CASE_RETRIEVE_S155]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CASE_RETRIEVE_S155] (
  @An_Office_IDNO  NUMERIC(3),
  @Ac_Role_ID      CHAR(10),
  @An_Case_IDNO    NUMERIC(6),
  @Ai_RowFrom_NUMB INT,
  @Ai_RowTo_NUMB   INT)
AS
  /*  
  *     PROCEDURE NAME    : CASE_RETRIEVE_S155  
  *     DESCRIPTION       : Retrieves the caseload totals of the workers based on the County.
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 02-SEP-2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
  */
  BEGIN
    DECLARE
      @Lc_OpenStatusCase_CODE                       CHAR(1) = 'O',
      @Lc_Initiating_International_RespondInit_CODE CHAR(1) = 'C',
      @Lc_Initiating_RespondInit_CODE               CHAR(1) = 'I',
      @Lc_Instate_RespondInit_CODE                  CHAR(1) = 'N',
      @Lc_Responding_RespondInit_CODE               CHAR(1) = 'R',
      @Lc_Responding_Tribal_RespondInit_CODE        CHAR(1) = 'S',
      @Lc_Initiating_Tribal_RespondInit_CODE        CHAR(1) = 'T',
      @Lc_Responding_International_RespondInit_CODE CHAR(1) = 'Y',
      @Lc_NONIVD_TypeCase_CODE                      CHAR(1) = 'H',
      @Lc_Yes_INDC                                  CHAR(1) = 'Y',
	  @Lc_No_INDC                                   CHAR(1) = 'N',
      @Lc_TanfTypeCase_CODE                         CHAR(1) = 'A',
      @Lc_NonTanfTypeCase_CODE                      CHAR(1) = 'N',
      @Lc_EstablishmentSpecialistRole_ID            CHAR(10) = 'RT001',
      @Lc_EnforcementSpecialistRole_ID              CHAR(10) = 'RE001',
      @Lc_CustomerServiceRepresentativeRole_ID      CHAR(10) = 'RC005',
      @Lc_IntergovernmentalSpecialistRole_ID        CHAR(10) = 'RS016',
      @Lc_High_Profile_SpecialistRole_ID            CHAR(10) = 'RS001',
      @Ld_Current_DATE                              DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
      @Ld_High_DATE                                 DATE = '12/31/9999';

    WITH RoleOffice_CTE(Office_IDNO, Role_ID)
         AS (SELECT @An_Office_IDNO AS Office_IDNO,
                    ISNULL(@Ac_Role_ID, (SELECT CASE
                                                 WHEN B.typecase_code=@Lc_NONIVD_TypeCase_CODE
                                                 THEN @Lc_CustomerServiceRepresentativeRole_ID
                                                 WHEN B.respondinit_code IN (@Lc_Initiating_RespondInit_CODE,
                                                                             @Lc_Instate_RespondInit_CODE)
                                                      AND B.Sord_INDC=@Lc_Yes_INDC 
                                                 THEN @Lc_EstablishmentSpecialistRole_ID
                                                 WHEN B.respondinit_code IN (@Lc_Initiating_International_RespondInit_CODE,
                                                                             @Lc_Initiating_RespondInit_CODE,
                                                                                   @Lc_Instate_RespondInit_CODE,
                                                                             @Lc_Initiating_Tribal_RespondInit_CODE)
                                                      AND B.Sord_INDC=@Lc_No_INDC
                                                 THEN @Lc_EnforcementSpecialistRole_ID
                                                 WHEN B.respondinit_code IN(@Lc_Responding_RespondInit_CODE,
                                                                            @Lc_Responding_Tribal_RespondInit_CODE,
                                                                            @Lc_Responding_International_RespondInit_CODE)
                                                 THEN @Lc_IntergovernmentalSpecialistRole_ID
                                                END AS Role_ID
                                           FROM (SELECT typecase_code,
                                                        respondinit_code,
                                                        ISNULL((SELECT TOP 1 @Lc_Yes_INDC 
                                                                  FROM SORD_Y1 X
                                                                 WHERE X.case_idno=@AN_Case_IDNO
                                                                   AND endvalidity_date=@Ld_High_DATE
                                                                   AND orderend_date>=@Ld_Current_DATE), @Lc_No_INDC) Sord_INDC
                                                   FROM CASE_Y1 B
                                                  WHERE B.case_idno=@AN_CASE_IDNO) b)) AS Role_ID),
         UsrtCase_CTE
         AS (SELECT C.highprofile_indc,
                    C.familial_indc,
                    C.WORKER_ID
               FROM USRT_Y1 C
              WHERE C.CASE_IDNO=@AN_CASE_IDNO
                AND C.endvalidity_date=@Ld_High_DATE
                AND @Lc_Yes_INDC IN (C.familial_indc, C.highprofile_indc)),
         UsrlCwrk_CTE(Case_IDNO, Role_ID, Worker_ID, CasesAssigned_QNTY)
         AS (SELECT CW.CASE_IDNO,
                    UR.Role_ID,
                    UR.Worker_ID,
                    UR.CasesAssigned_QNTY
               FROM (SELECT CW.CASE_IDNO,
                            CW.ROLE_ID,
                            CW.worker_ID,
                            CW.Office_IDNO
                       FROM CWRK_Y1 CW,
                            RoleOffice_CTE RL
                      WHERE CW.Office_IDNO=RL.Office_IDNO
                        AND CW.ROLE_ID=RL.Role_ID
                        AND cw.Effective_DATE<=@Ld_Current_DATE
                        AND cw.Expire_DATE>@Ld_Current_DATE
                        AND CW.EndValidity_DATE=@Ld_High_DATE) cw
                    RIGHT OUTER JOIN (SELECT UR.Role_ID,
                                             UR.Worker_ID,
                                             UR.CasesAssigned_QNTY,
                                             UR.Office_IDNO
                                        FROM USRL_Y1 UR, UASM_Y1 US,
                                             RoleOffice_CTE RL
                                       WHERE UR.Office_IDNO=RL.Office_IDNO
									     AND UR.Office_IDNO=US.Office_IDNO
                                         AND UR.Role_ID=RL.Role_ID
                                         AND UR.WORKER_ID= US.WORKER_ID
                                         AND UR.Effective_DATE <= @Ld_Current_DATE
                                         AND US.Effective_DATE<=@Ld_Current_DATE
                                         AND UR.Expire_DATE>=@Ld_Current_DATE
                                         AND US.Expire_DATE >= @Ld_Current_DATE
                                         AND UR.EndValidity_DATE = @Ld_High_DATE
                                         AND US.EndValidity_DATE = @Ld_High_DATE) ur
                      ON CW.worker_ID=UR.worker_ID
                         AND UR.Office_IDNO=CW.Office_IDNO
                         AND CW.Role_ID=UR.Role_ID
              /*Added Newly*/
              WHERE NOT EXISTS
                        (SELECT 1
                           FROM UsrtCase_CTE C
                          WHERE UR.WORKER_ID=C.WORKER_ID
                            AND C.familial_indc=@Lc_Yes_INDC)
                AND NOT EXISTS
                        (SELECT 1
                           FROM UsrtCase_CTE C
                          WHERE C.highprofile_indc=@Lc_Yes_INDC
                            AND NOT EXISTS
                                    (SELECT 1
                                       FROM USRL_Y1 B
                                      WHERE UR.WORKER_ID=B.WORKER_ID
                                        AND B.OFFICE_IDNO=@AN_OFFICE_IDNO
                                        AND B.ROLE_ID=@Lc_High_Profile_SpecialistRole_ID
                                        AND b.Effective_DATE<=@Ld_Current_DATE
                                        AND b.Expire_DATE>=@Ld_Current_DATE
                                        AND b.EndValidity_DATE=@Ld_High_DATE)))
    /*Added Newly*/
    SELECT Worker_ID,
           Role_ID,
           InterstateInitiating_NUMB,
           InterstateInstate_NUMB,
           InterstateResponding_NUMB,
           TypeCaseTanf_NUMB,
           TypeCaseNonTanf_NUMB,
           TypeCaseOther_NUMB,
           TOTALCASELOAD_QNTY,
           RowCount_Numb
      FROM (SELECT b.Worker_id,
                   b.Role_ID,
                   SUM(CASE
                        WHEN a.respondinit_CODE IN (@Lc_Initiating_International_RespondInit_CODE,
                                                    @Lc_Initiating_RespondInit_CODE,
                                                    @Lc_Initiating_Tribal_RespondInit_CODE)
                        THEN 1
                        ELSE 0
                       END) InterstateInitiating_NUMB,
                   SUM(CASE
                        WHEN a.respondinit_CODE=@Lc_Instate_RespondInit_CODE
                        THEN 1
                        ELSE 0
                       END) InterstateInstate_NUMB,
                   SUM(CASE
                        WHEN a.respondinit_CODE IN (@Lc_Responding_RespondInit_CODE, @Lc_Responding_Tribal_RespondInit_CODE,
                                                    @Lc_Responding_International_RespondInit_CODE)
                        THEN 1
                        ELSE 0
                       END) InterstateResponding_NUMB,
                   SUM(CASE
                        WHEN a.TypeCase_CODE=@Lc_TanfTypeCase_CODE
                        THEN 1
                        ELSE 0
                       END) TypeCaseTanf_NUMB,
                   SUM(CASE
                        WHEN a.TypeCase_CODE=@Lc_NonTanfTypeCase_CODE
                        THEN 1
                        ELSE 0
                       END) TypeCaseNonTanf_NUMB,
                   SUM(CASE
                        WHEN a.TypeCase_CODE NOT IN (@Lc_TanfTypeCase_CODE, @Lc_NonTanfTypeCase_CODE)
                        THEN 1
                        ELSE 0
                       END) TypeCaseOther_NUMB,
                   MAX(CasesAssigned_QNTY) AS TOTALCASELOAD_QNTY,
                   ROW_NUMBER() OVER(ORDER BY b.worker_ID) Row_NUMB,
                   COUNT(1) OVER() rowcount_numb
              FROM CASE_Y1 a
                   RIGHT OUTER JOIN UsrlCwrk_CTE b
                     ON a.StatusCase_CODE=@Lc_OpenStatusCase_CODE
                        AND a.case_idno=b.case_idno
             GROUP BY b.worker_id,
                      B.Role_ID) x
     WHERE ROW_NUMB BETWEEN @Ai_RowFrom_NUMB AND @Ai_RowTo_NUMB;
  END


GO
