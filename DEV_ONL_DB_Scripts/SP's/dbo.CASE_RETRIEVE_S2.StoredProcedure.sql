/****** Object:  StoredProcedure [dbo].[CASE_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--CASE_RETRIEVE_S2 3,'RT001',null,1,1000
CREATE PROCEDURE [dbo].[CASE_RETRIEVE_S2] (
  @An_Office_IDNO  NUMERIC(3),
  @Ac_Role_ID      CHAR(10),
  @An_Case_IDNO    NUMERIC(6, 0),
  @Ai_RowFrom_NUMB INT,
  @Ai_RowTo_NUMB   INT)
AS
  /*  
  *     PROCEDURE NAME    : CASE_RETRIEVE_S2  
  *     DESCRIPTION       : Retrieves the caseload totals of the workers based on the County.
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 02-SEP-2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
  */
  BEGIN
    DECLARE
      @Lc_OpenStatusCase_CODE            CHAR(1) = 'O',
      @Lc_RespondRespondInit_CODE        CHAR(1) = 'I',
      @Lc_NonInterstate_RespondInit_CODE CHAR(1) = 'N',
      @Lc_InitRespondInit_CODE           CHAR(1) = 'R',
      @Lc_Space_TEXT                     CHAR(1) = ' ',
      @Lc_NonTanfTypeCase_CODE    CHAR(1) = 'N',
	  
	  @Lc_Initiating_International_RespondInit_CODE CHAR(1) = 'C',
	  @Lc_Initiating_RespondInit_CODE               CHAR(1) = 'I',
	  @Lc_Initiating_Tribal_RespondInit_CODE        CHAR(1) = 'T',
	  
	  @Lc_Instate_RespondInit_CODE                  CHAR(1) = 'N',
	  
	  @Lc_Responding_RespondInit_CODE               CHAR(1) = 'R',
	  @Lc_Responding_Tribal_RespondInit_CODE        CHAR(1) = 'S',
	  @Lc_Responding_International_RespondInit_CODE CHAR(1) = 'Y',
      
      @Lc_TanfTypeCase_CODE       CHAR(1) = 'A',
      @Ld_Current_DATE                   DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
      @Ld_High_DATE                      DATE = '12/31/9999';

    WITH b(Case_IDNO, Worker_ID,CasesAssigned_QNTY)
         AS (SELECT CW.CASE_IDNO,
                    UR.Worker_ID,
                    UR.CasesAssigned_QNTY
               FROM (SELECT *
                       FROM CWRK_Y1 CW
                      WHERE CW.Office_IDNO=@An_Office_IDNO
                        AND CW.ROLE_ID=@Ac_Role_ID
                        AND cw.Effective_DATE<=@Ld_Current_DATE
                        AND cw.Expire_DATE>@Ld_Current_DATE
                        AND CW.EndValidity_DATE=@Ld_High_DATE) cw
                    RIGHT OUTER JOIN (SELECT *
                                        FROM USRL_Y1 UR
                                       WHERE UR.Office_IDNO=@An_Office_IDNO
										 AND UR.Role_ID=@Ac_Role_ID
										 AND UR.Effective_DATE<=@Ld_Current_DATE
                                         AND UR.Expire_DATE>=@Ld_Current_DATE
                                         AND UR.EndValidity_DATE=@Ld_High_DATE) ur
                      ON CW.worker_ID=UR.worker_ID
                         AND UR.Office_IDNO=CW.Office_IDNO
                         AND CW.Role_ID=UR.Role_ID
              /*Added Newly*/
              WHERE (EXISTS
                     (SELECT 1
                        FROM USRT_Y1 C
                       WHERE C.CASE_IDNO=@AN_CASE_IDNO
                         AND C.endvalidity_date='31-dec-9999'
                         AND C.highprofile_indc='Y'
                         AND EXISTS
                             (SELECT 1
                                FROM USRL_Y1 B
                               WHERE UR.WORKER_ID=B.WORKER_ID
                                 AND B.OFFICE_IDNO=@AN_OFFICE_IDNO
                                 AND B.ROLE_ID='RS001'
                                 AND b.Effective_DATE<=@Ld_Current_DATE
                                 AND b.Expire_DATE>=@Ld_Current_DATE
                                 AND b.EndValidity_DATE=@Ld_High_DATE))
                      OR NOT EXISTS
                             (SELECT 1
                                FROM USRT_Y1 C
                               WHERE C.CASE_IDNO=@AN_CASE_IDNO
                                 AND C.endvalidity_date='31-dec-9999'
                                 AND C.highprofile_indc='Y'))
                AND (EXISTS
                     (SELECT 1
                        FROM USRT_Y1 C
                       WHERE C.CASE_IDNO=@AN_CASE_IDNO
                         AND C.endvalidity_date='31-dec-9999'
                         AND C.familial_indc='Y'
                         AND UR.WORKER_ID<>C.WORKER_ID)
                      OR NOT EXISTS
                             (SELECT 1
                                FROM USRT_Y1 C
                               WHERE C.CASE_IDNO=@AN_CASE_IDNO
                                 AND C.endvalidity_date='31-dec-9999'
                                 AND C.familial_indc='Y'))
                                 )
    /*Added Newly*/
    SELECT Worker_ID,
           InterstateInitiating_NUMB,
           InterstateInstate_NUMB,
           InterstateResponding_NUMB,
           TypeCaseTanf_NUMB,
           TypeCaseNonTanf_NUMB,
           TypeCaseOther_NUMB,
           TOTALCASELOAD_QNTY,
           RowCount_Numb
      FROM (SELECT b.Worker_id,
                   SUM(CASE
                        WHEN a.respondinit_CODE IN (@Lc_Initiating_International_RespondInit_CODE,@Lc_Initiating_RespondInit_CODE,@Lc_Initiating_Tribal_RespondInit_CODE)
                        THEN 1
                        ELSE 0
                       END) InterstateInitiating_NUMB,
                   SUM(CASE
                        WHEN a.respondinit_CODE=@Lc_Instate_RespondInit_CODE
                        THEN 1
                        ELSE 0
                       END) InterstateInstate_NUMB,
                   SUM(CASE
                        WHEN a.respondinit_CODE IN (@Lc_Responding_RespondInit_CODE,@Lc_Responding_Tribal_RespondInit_CODE,@Lc_Responding_International_RespondInit_CODE)
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
              FROM case_y1 a
                   RIGHT OUTER JOIN b
                     ON a.StatusCase_CODE=@Lc_OpenStatusCase_CODE
                        AND a.case_idno=b.case_idno
             GROUP BY b.worker_id) x
     WHERE ROW_NUMB BETWEEN @Ai_RowFrom_NUMB AND @Ai_RowTo_NUMB
  END

GO
