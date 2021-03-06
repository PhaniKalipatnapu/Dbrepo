/****** Object:  StoredProcedure [dbo].[USRL_RETRIEVE_S5]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
*     PROCEDURE NAME    : USRL_RETRIEVE_S5
*     DESCRIPTION       : Retrieve Worker Idno, Role Idno, and other details for an Office,
*                         Case Idno, Member Idno, Role Idno, and where Case Status of a Member is Active.
*     DEVELOPED BY      : IMP Team
*     DEVELOPED ON      : 10-SEP-2011
*     MODIFIED BY       : 
*     MODIFIED ON       : 
*     VERSION NO        : 1
*/

CREATE PROCEDURE [dbo].[USRL_RETRIEVE_S5](
  @An_Office_IDNO  NUMERIC(3),
  @An_Case_IDNO    NUMERIC(6, 0),
  @Ac_Role_ID      CHAR(10),
  @Ai_RowFrom_NUMB INT,
  @Ai_RowTo_NUMB   INT)
AS
  BEGIN
    DECLARE
      @Lc_CaseStatusOpen_CODE            CHAR(1) = 'O',
      @Lc_CpRelationshipCase_CODE        CHAR(1) = 'C',
      @Lc_NcpRelationshipCase_CODE       CHAR(1) = 'A',
      @Lc_Putative_RelationshipCase_CODE CHAR(1) = 'P',
      @Lc_StatusCaseMemberActive_CODE    CHAR(1) = 'A',
      @Lc_Yes_INDC                       CHAR(1) = 'Y',
      @Lc_HighProfileSpecialistRole_ID   CHAR(10)='RS001',
	  @Ln_MemberMciUnknown_IDNO			 NUMERIC(10) = 999995,
      @Ld_High_DATE                      DATE = '12/31/9999',
      @Ld_Current_DATE                   DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
      @Lc_EstablishmentSpecialistRole_ID            CHAR(10) = 'RT001',
      @Lc_EnforcementSpecialistRole_ID              CHAR(10) = 'RE001',
      @Lc_CustomerServiceRepresentativeRole_ID      CHAR(10) = 'RC005',
      @Lc_IntergovernmentalSpecialistRole_ID        CHAR(10) = 'RS016',
      @Lc_High_Profile_SpecialistRole_ID            CHAR(10) = 'RS001',
      @Lc_Initiating_International_RespondInit_CODE CHAR(1) = 'C',
      @Lc_Initiating_RespondInit_CODE               CHAR(1) = 'I',
      @Lc_Instate_RespondInit_CODE                  CHAR(1) = 'N',
      @Lc_Responding_RespondInit_CODE               CHAR(1) = 'R',
      @Lc_Responding_Tribal_RespondInit_CODE        CHAR(1) = 'S',
      @Lc_Initiating_Tribal_RespondInit_CODE        CHAR(1) = 'T',
      @Lc_Responding_International_RespondInit_CODE CHAR(1) = 'Y',
      @Lc_NONIVD_TypeCase_CODE                      CHAR(1) = 'H';
      

    WITH RoleOffice_CTE(Office_IDNO, Role_ID)
         AS (SELECT @An_Office_IDNO AS Office_IDNO,
                    ISNULL(@Ac_Role_ID, (SELECT CASE
                                                 WHEN B.typecase_code=@Lc_NONIVD_TypeCase_CODE
                                                 THEN @Lc_CustomerServiceRepresentativeRole_ID
                                                 WHEN B.respondinit_code IN (@Lc_Initiating_RespondInit_CODE,
                                                                             @Lc_Instate_RespondInit_CODE)
                                                      AND NOT EXISTS
                                                              (SELECT 1
                                                                 FROM SORD_Y1 X
                                                                WHERE X.case_idno=@AN_Case_IDNO
                                                                  AND endvalidity_date=@Ld_High_DATE
                                                                  AND orderend_date>=@Ld_Current_DATE)
                                                 THEN @Lc_EstablishmentSpecialistRole_ID
                                                 WHEN B.respondinit_code IN (@Lc_Initiating_International_RespondInit_CODE,
                                                                             @Lc_Initiating_RespondInit_CODE,
                                                                                   @Lc_Instate_RespondInit_CODE,
                                                                             @Lc_Initiating_Tribal_RespondInit_CODE)
                                                      AND EXISTS
                                                          (SELECT 1
                                                             FROM SORD_Y1 X
                                                            WHERE X.case_idno=@AN_Case_IDNO
                                                              AND endvalidity_date=@Ld_High_DATE
                                                              AND orderend_date>=@Ld_Current_DATE)
                                                 THEN @Lc_EnforcementSpecialistRole_ID
                                                 WHEN B.respondinit_code IN(@Lc_Responding_RespondInit_CODE,
                                                                            @Lc_Responding_Tribal_RespondInit_CODE,
                                                                            @Lc_Responding_International_RespondInit_CODE)
                                                 THEN @Lc_IntergovernmentalSpecialistRole_ID
                                                END AS Role_ID
                                           FROM CASE_Y1 B
                                          WHERE B.case_idno=@AN_CASE_IDNO)) AS Role_ID),
         WorkLoad_CTE(Worker_ID,ROLE_ID, Row_NUMB, RowCount_NUMB)
         AS (SELECT Y.Worker_ID,
					Y.ROLE_ID,
                    Y.Row_NUMB,
                    Y.RowCount_NUMB
               FROM (SELECT X.Worker_ID,
							X.ROLE_ID,
                            ROW_NUMBER() OVER( ORDER BY X.Worker_ID) AS Row_NUMB,
                            COUNT(1) OVER() AS RowCount_NUMB
                       FROM (SELECT DISTINCT
                                    u.Worker_ID,
                                    u.ROLE_ID
                               FROM USRL_Y1 u, UASM_Y1 US,
                                    RoleOffice_CTE RL
                              WHERE u.Office_IDNO=RL.Office_IDNO
                                AND u.Office_IDNO=US.Office_IDNO
                                AND u.WORKER_ID= US.WORKER_ID
                                AND u.ROLE_ID=RL.Role_ID
                                AND u.Effective_DATE<=@Ld_Current_DATE
                                AND US.Effective_DATE<=@Ld_Current_DATE
                                AND u.Expire_DATE>=@Ld_Current_DATE
                                AND US.Expire_DATE>=@Ld_Current_DATE
                                AND u.Expire_DATE>=@Ld_Current_DATE
                                AND US.EndValidity_DATE=@Ld_High_DATE
                                AND u.EndValidity_DATE=@Ld_High_DATE                                
                                AND (EXISTS
                                     (SELECT 1
                                        FROM USRT_Y1 C
                                       WHERE C.CASE_IDNO=@AN_CASE_IDNO
                                         AND C.endvalidity_date=@Ld_High_DATE
                                         AND C.highprofile_indc=@Lc_Yes_INDC
                                         AND EXISTS
                                             (SELECT 1
                                                FROM USRL_Y1 B
                                               WHERE U.WORKER_ID=B.WORKER_ID
                                                 AND B.OFFICE_IDNO=@AN_OFFICE_IDNO
                                                 AND B.ROLE_ID=@Lc_HighProfileSpecialistRole_ID
                                                 AND b.Effective_DATE<=@Ld_Current_DATE
                                                 AND b.Expire_DATE>=@Ld_Current_DATE
                                                 AND b.EndValidity_DATE=@Ld_High_DATE))
                                      OR NOT EXISTS
                                             (SELECT 1
                                                FROM USRT_Y1 C
                                               WHERE C.CASE_IDNO=@AN_CASE_IDNO
                                                 AND C.endvalidity_date=@Ld_High_DATE
                                                 AND C.highprofile_indc=@Lc_Yes_INDC))
                                AND (EXISTS
                                     (SELECT 1
                                        FROM USRT_Y1 C
                                       WHERE C.CASE_IDNO=@AN_CASE_IDNO
                                         AND C.endvalidity_date=@Ld_High_DATE
                                         AND C.familial_indc=@Lc_Yes_INDC
                                         AND u.WORKER_ID<>C.WORKER_ID)
                                      OR NOT EXISTS
                                             (SELECT 1
                                                FROM USRT_Y1 C
                                               WHERE C.CASE_IDNO=@AN_CASE_IDNO
                                                 AND C.endvalidity_date=@Ld_High_DATE
                                                 AND C.familial_indc=@Lc_Yes_INDC))
                            ) X) Y
              WHERE Y.Row_NUMB BETWEEN @Ai_RowFrom_NUMB AND @Ai_RowTo_NUMB)
      SELECT CTE.Worker_ID,
             CTE.ROLE_ID,
			 CTE.Row_NUMB,
			 CTE.RowCount_NUMB,
			 WL.Alpha_TEXT,
			 WL.AlphaLoadSum_NUMB
		FROM  WorkLoad_CTE CTE
			 LEFT OUTER JOIN
			  (  SELECT IL.Worker_ID,
						IL.Alpha_TEXT,
						COUNT(IL.Alpha_TEXT) AS AlphaLoadSum_NUMB
				   FROM (SELECT TL.Worker_ID,
								ISNULL(
								 LEFT(
								  (SELECT D.Last_NAME
									 FROM DEMO_Y1 D,
										  CMEM_Y1 CM
									WHERE CM.MemberMci_IDNO = D.MemberMci_IDNO
									  AND C.Case_IDNO = CM.Case_IDNO
									  AND (CM.CaseRelationship_CODE = @Lc_NcpRelationshipCase_CODE
									   AND 1 =
											(SELECT COUNT(1)
											   FROM CMEM_Y1 Z
											  WHERE Z.Case_IDNO = C.Case_IDNO
												AND Z.caserelationship_code IN
													 (@Lc_Putative_RelationshipCase_CODE, @Lc_NcpRelationshipCase_CODE)
												AND Z.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE)
										OR (CM.CaseRelationship_CODE = @Lc_Putative_RelationshipCase_CODE
										AND D.MemberMci_IDNO != @Ln_MemberMciUnknown_IDNO
										AND 1 =
											 (SELECT COUNT(1)
												FROM CMEM_Y1 Z
											   WHERE Z.Case_IDNO = C.Case_IDNO
												 AND Z.caserelationship_code IN
													  (@Lc_Putative_RelationshipCase_CODE, @Lc_NcpRelationshipCase_CODE)
												 AND Z.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE)))
									  AND CM.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE),
								  1),
								 LEFT((SELECT D.Last_NAME
										 FROM DEMO_Y1 D,
											  CMEM_Y1 CM
										WHERE CM.MemberMci_IDNO = D.MemberMci_IDNO
										  AND C.Case_IDNO = CM.Case_IDNO
										  AND CM.CaseRelationship_CODE = @Lc_CpRelationshipCase_CODE
										  AND CM.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE),
									  1))
								 AS Alpha_TEXT
						   FROM WorkLoad_CTE TL
							   JOIN (SELECT W.case_idno,
											W.worker_ID
									   FROM CWRK_Y1 W, RoleOffice_CTE RL
									  WHERE W.Role_ID = RL.Role_ID
										AND W.Office_idno = RL.Office_IDNO
										AND W.Effective_DATE <= @Ld_Current_DATE
										AND W.Expire_DATE > @Ld_Current_DATE
										AND W.EndValidity_DATE = @Ld_High_DATE) w
								ON W.worker_ID = TL.worker_ID
							   JOIN CASE_Y1 C
								ON c.Case_idno = W.case_idno
						  WHERE C.StatusCase_CODE = @Lc_CaseStatusOpen_CODE) IL
			   GROUP BY IL.Worker_ID,
						IL.Alpha_TEXT) WL
			 ON CTE.Worker_ID = WL.Worker_ID
	ORDER BY CTE.Row_NUMB;
  END


GO
