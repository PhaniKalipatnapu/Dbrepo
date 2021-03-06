/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_GET_ALERT_WORKER_ID]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
------------------------------------------------------------------------------------------------------------------
 Procedure Name	: BATCH_COMMON$SP_GET_ALERT_WORKER_ID
 Programmer Name: IMP Team
 Description	: This procedure is used to assign a worker for an alert
 Frequency		:
 Developed On	: 04/12/2011
 Called By		:
 Called On		:
------------------------------------------------------------------------------------------------------------------
 Modified By	:
 Modified On	:
 Version No		:  1.0
------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_GET_ALERT_WORKER_ID] (
 @An_Case_IDNO             NUMERIC(6),
 @Ac_Case_Worker_ID        CHAR(30),
 @An_Office_IDNO           NUMERIC(3) = 0,
 @Ad_Run_DATE              DATE,
 @Ac_SignedonWorker_ID     CHAR(30),
 @Ac_Acrl_INDC             CHAR(1) = 'N',
 @Ac_Job_ID                CHAR(7) = ' ',
 @Ac_Role_ID               CHAR(5) = ' ' OUTPUT,
 @Ac_Worker_ID             CHAR(30) OUTPUT,
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Li_Error_NUMB             INT,
          @Li_ErrorLine_NUMB         INT,
          @Lc_StatusFailed_CODE      CHAR(1)		= 'F',
          @Lc_StatusSuccess_CODE     CHAR(1)		= 'S',
          @Lc_Supervisor_CODE        CHAR(1)		= 'S',
          @Lc_Yes_INDC               CHAR(1)		= 'Y',
          @Lc_RespondInitC_CODE      CHAR(1)		= 'C',
          @Lc_RespondInitI_CODE      CHAR(1)		= 'I',
          @Lc_RespondInitT_CODE      CHAR(1)		= 'T',
          @Lc_CaseRelationshipC_CODE CHAR(1)		= 'C',
          @Lc_CaseRelationshipA_CODE CHAR(1)		= 'A',
          @Lc_CaseRelationshipP_CODE CHAR(1)		= 'P',
          @Lc_CaseMemberStatusA_CODE CHAR(1)		= 'A',
          @Lc_JobAsmt_ID             CHAR(4)		= 'ASMT',
          @Lc_JobUsem_ID             CHAR(4)		= 'USEM',
          @Lc_JobRstr_ID             CHAR(4)		= 'RSTR',
          @Lc_WorkerBatch_ID         CHAR(5)		= 'BATCH',
          @Lc_RoleRs016_ID           CHAR(5)		= 'RS016', 
          @Lc_RoleRs002_ID           CHAR(5)		= 'RS002',
          @Lc_RoleRs001_ID           CHAR(5)		= 'RS001',
          @Lc_RoleRe001_ID           CHAR(5)		= 'RE001',
          @Lc_RoleRt001_ID           CHAR(5)		= 'RT001',
          @Lc_RoleRp004_ID           CHAR(5)		= 'RP004',
          @Lc_ErrorE1354_CODE        CHAR(5)		= 'E1354',
          @Lc_ErrorE1216_CODE        CHAR(5)		= 'E1216',
          @Lc_ErrorE0519_CODE        CHAR(5)		= 'E0519',
          @Ls_Procedure_NAME         VARCHAR(100)	= 'BATCH_COMMON$SP_GET_ALERT_WORKER_ID',
          @Ld_High_DATE              DATE			= '12/31/9999';
  DECLARE @Ln_Usrl_Count_NUMB                  NUMERIC(2),
          @Ln_CasePf_Count_NUMB                NUMERIC(2),
          @Ln_UnidentifiedPf_Count_NUMB        NUMERIC(2),
          @Ln_HighProfile_NUMB                 NUMERIC(2),
          @Ln_Familial_NUMB                    NUMERIC(2),
          @Ln_RoleWorkers_Usrl_Count_NUMB      NUMERIC(5),
          @Ln_NotAlphaAssigned_Usrl_Count_NUMB NUMERIC(5),
          @Lc_RespondInit_CODE                 CHAR(1),
          @Lc_3CharOfLast_NAME                 CHAR(3),
          @Ls_Sql_TEXT                         VARCHAR(100),
          @Ls_Sqldata_TEXT                     VARCHAR(1000),
          @Ls_ErrorMessage_TEXT				   VARCHAR(4000),
          @Ld_OrderEnd_DATE                    DATE,
          @Ld_CaseOpened_DATE                  DATE;

  BEGIN TRY
  
	/*
		Case will be assiging to RE001(Sord Exists) or RT001 while transfering case from Center County(99) with RS002 Role
	*/
	-- 13692 - Cases cannot be manually reassigned in ICR/Central as they can be in other counties - Start
	IF ( @Ac_Role_ID = @Lc_RoleRs002_ID 
			AND @Ac_Job_ID = @Lc_JobAsmt_ID 
			AND @An_Office_IDNO != 99 )
		BEGIN	
			IF EXISTS ( SELECT 1 
						  FROM CASE_Y1 c 
						 WHERE c.Case_IDNO = @An_Case_IDNO 
						   AND c.County_IDNO = 99)
				BEGIN
					--- Remove 'RS002' role. need to assing to new role
					IF EXISTS (SELECT 1 
								 FROM SORD_Y1 s
								WHERE s.Case_IDNO = @An_Case_IDNO 
								  AND s.EndValidity_DATE = @Ld_High_DATE)
					BEGIN 
						SET @Ac_Role_ID = @Lc_RoleRe001_ID;
					END
					ELSE 
					BEGIN
						SET @Ac_Role_ID = @Lc_RoleRt001_ID;
					END
				END
		END
	-- 13692 - Cases cannot be manually reassigned in ICR/Central as they can be in other counties - End

   -- If ACRL_Y1.WorkerAssign_INDC = 'Y' and ACRL_Y1.Role_ID = '' then assign Case Worker ID for the alert
   IF (@Ac_Role_ID IS NULL
        OR @Ac_Role_ID = '')
      AND @Ac_Acrl_INDC = @Lc_Yes_INDC
    BEGIN
     SET @Ac_Worker_ID = @Ac_Case_Worker_ID;
     SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;

     RETURN;
    END

   -- Get the Supervisor of the Worker When @Ac_Role_ID = S (ACRL_Y1.WorkerAssign_INDC = 'S')
   IF (@Ac_Role_ID IS NOT NULL
       AND @Ac_Role_ID = @Lc_Supervisor_CODE)
      AND @Ac_Acrl_INDC = @Lc_Yes_INDC
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT RespondInit_CODE VALUES FROM CASE_Y1';
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'');
     
     SELECT @Lc_RespondInit_CODE = a.RespondInit_CODE
       FROM CASE_Y1 a
      WHERE a.Case_IDNO = @An_Case_IDNO;

     IF @Lc_RespondInit_CODE IN (@Lc_RespondInitC_CODE, @Lc_RespondInitI_CODE, @Lc_RespondInitT_CODE)
      BEGIN
       SET @Ac_Role_ID = @Lc_RoleRs016_ID;
      END
     ELSE
      BEGIN
       SET @Ls_Sql_TEXT = 'SELECT OrderEnd_DATE VALUES FROM SORD_Y1';
       SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');
       
       SELECT @Ld_OrderEnd_DATE = OrderEnd_DATE
         FROM SORD_Y1 s
        WHERE s.Case_IDNO = @An_Case_IDNO
          AND s.EndValidity_DATE = @Ld_High_DATE;

       SET @Ls_Sql_TEXT = 'SELECT Opened_DATE VALUES FROM CASE_Y1';
       SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'');
       
       SELECT @Ld_CaseOpened_DATE = Opened_DATE
         FROM CASE_Y1 s
        WHERE s.Case_IDNO = @An_Case_IDNO;


       IF @Ld_OrderEnd_DATE >= @Ld_CaseOpened_DATE
        BEGIN
         SET @Ac_Role_ID = @Lc_RoleRe001_ID;
        END
       ELSE
        BEGIN
         SET @Ac_Role_ID = @Lc_RoleRt001_ID;
        END
      END

     SET @Ls_Sql_TEXT = 'SELECT Supervisor_ID VALUES FROM USRL_Y1';
     SET @Ls_Sqldata_TEXT = 'Worker_ID = ' + ISNULL(@Ac_Case_Worker_ID,'')+ ', Office_IDNO = ' + ISNULL(CAST( @An_Office_IDNO AS VARCHAR ),'')+ ', Role_ID = ' + ISNULL(@Ac_Role_ID,'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

     SELECT @Ac_Worker_ID = u.Supervisor_ID
       FROM USRL_Y1 u
      WHERE u.Worker_ID = @Ac_Case_Worker_ID
        AND u.Office_IDNO = @An_Office_IDNO
        AND u.Role_ID = @Ac_Role_ID
        AND u.EndValidity_DATE = @Ld_High_DATE
        AND @Ad_Run_DATE BETWEEN u.Effective_DATE AND u.Expire_DATE;
        
	IF @Ac_Worker_ID IS NULL OR @Ac_Worker_ID = ''
	BEGIN
		SET @Ac_Msg_CODE = @Lc_ErrorE0519_CODE;
	END
	ELSE
	BEGIN
		SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;	
	END
		
    SET @Ac_Role_ID = '';
     RETURN;
    END

   IF @Ac_Worker_ID IS NOT NULL
      AND @Ac_Worker_ID != ''
    BEGIN
     SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;

     RETURN;
    END

   SET @Ls_Sql_TEXT = 'CHECK THE COUNT FROM USRT_Y1 - 1';
   SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', HighProfile_INDC = ' + ISNULL(@Lc_Yes_INDC,'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');	
   
   SELECT @Ln_HighProfile_NUMB = COUNT(1)
     FROM USRT_Y1 t
    WHERE t.Case_IDNO = @An_Case_IDNO
      AND t.HighProfile_INDC = @Lc_Yes_INDC
      AND t.EndValidity_DATE = @Ld_High_DATE;

   SET @Ls_Sql_TEXT = 'CHECK THE COUNT FROM USRT_Y1 - 2';
   SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', HighProfile_INDC = ' + ISNULL(@Lc_Yes_INDC,'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');	
   SELECT @Ln_Familial_NUMB = COUNT(1)
     FROM USRT_Y1 t
    WHERE t.Case_IDNO = @An_Case_IDNO
      AND t.Familial_INDC = @Lc_Yes_INDC
      AND t.EndValidity_DATE = @Ld_High_DATE;

   IF (@Ac_Worker_ID = ''
        OR @Ac_Worker_ID IS NULL)
      AND (@Ac_Case_Worker_ID != ''
           AND @Ac_Case_Worker_ID IS NOT NULL)
      AND @Ac_Job_ID != @Lc_JobUsem_ID
      AND @Ac_Role_ID NOT IN (SELECT Role_ID
                                FROM #PrimaryRole_P1)
    BEGIN
     IF @Ac_SignedonWorker_ID != @Lc_WorkerBatch_ID
      BEGIN
       -- Check whether the case worker has the given role in case office and no worker has been assigned for this case and role combination in CWRK
       SET @Ls_Sql_TEXT = 'CHECK THE COUNT FROM USRL_Y1';
	   SET @Ls_Sqldata_TEXT = 'Worker_ID = ' + ISNULL(@Ac_Case_Worker_ID,'')+ ', Office_IDNO = ' + ISNULL(CAST( @An_Office_IDNO AS VARCHAR ),'')+ ', Role_ID = ' + ISNULL(@Ac_Role_ID,'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', Role_ID = ' + ISNULL(@Ac_Role_ID,'')+ ', Office_IDNO = ' + ISNULL(CAST( @An_Office_IDNO AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', Role_ID = ' + ISNULL(@Lc_RoleRs001_ID,'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', Familial_INDC = ' + ISNULL(@Lc_Yes_INDC,'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');
       SELECT @Ln_Usrl_Count_NUMB = COUNT(1)
         FROM USRL_Y1 ur
        WHERE ur.Worker_ID = @Ac_Case_Worker_ID
          AND ur.Office_IDNO = @An_Office_IDNO
          AND ur.Role_ID = @Ac_Role_ID
          -- 13573 Case reassignment batch populated incorrect total case load - Type Casting removed -- Start
          AND ur.Effective_DATE <= @Ad_Run_DATE
          AND ur.Expire_DATE > @Ad_Run_DATE
          -- 13573 Case reassignment batch populated incorrect total case load - Type Casting removed -- End
          AND ur.EndValidity_DATE = @Ld_High_DATE
          AND NOT EXISTS(SELECT 1
                           FROM CWRK_Y1 cw
                          WHERE cw.Case_IDNO = @An_Case_IDNO
                            AND cw.Worker_ID != @Ac_Case_Worker_ID
                            AND cw.Role_ID = @Ac_Role_ID
                            AND cw.Office_IDNO = @An_Office_IDNO
                            AND cw.Effective_DATE <= @Ad_Run_DATE
                            AND cw.Expire_DATE > @Ad_Run_DATE
                            AND cw.EndValidity_DATE = @Ld_High_DATE)
          -- High Profile Case then Case Restriction Manager Role
          AND ((@Ln_HighProfile_NUMB >= 1
                AND EXISTS (SELECT 1
                              FROM USRL_Y1 z
                             WHERE z.Worker_ID = ur.Worker_ID
                         
                               AND z.Office_IDNO = ur.Office_IDNO
                               AND z.Role_ID = @Lc_RoleRs001_ID 
                               AND z.Effective_DATE <= @Ad_Run_DATE
                               AND z.Expire_DATE > @Ad_Run_DATE
                               AND z.EndValidity_DATE = @Ld_High_DATE))
                OR (@Ln_HighProfile_NUMB = 0))
          -- Familial Case then worker should not be familiar with the case
          AND ((@Ln_Familial_NUMB = 0)
                OR (@Ln_Familial_NUMB > 0
                    AND NOT EXISTS (SELECT 1
                                      FROM USRT_Y1 t
                                     WHERE t.Case_IDNO = @An_Case_IDNO
                                       AND t.Familial_INDC = @Lc_Yes_INDC
                                       AND t.Worker_ID = ur.Worker_ID
                                       AND t.EndValidity_DATE = @Ld_High_DATE)));
       /* Case Worker has the specified Role in the Case County 
          and no worker has been assigned in CWRK_Y1 for this case and specified Role in the Case County 
       */
       IF @Ln_Usrl_Count_NUMB != 0
        BEGIN
         SET @Ac_Worker_ID = @Ac_Case_Worker_ID;
        END
        -- If already a worker assigned for the case in CWRK_Y1, then get that Worker_ID
       ELSE
        BEGIN
         SET @Ls_Sql_TEXT = 'SELECT WORKER THAT HAS THE ROLE FROM CWRK_Y1';
         SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', Role_ID = ' + ISNULL(@Ac_Role_ID,'')+ ', Office_IDNO = ' + ISNULL(CAST( @An_Office_IDNO AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', Role_ID = ' + ISNULL(@Lc_RoleRs001_ID,'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', Familial_INDC = ' + ISNULL(@Lc_Yes_INDC,'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

         SELECT @Ac_Worker_ID = cw.Worker_ID
           FROM CWRK_Y1 cw
          WHERE cw.Case_IDNO = @An_Case_IDNO
            AND cw.Role_ID = @Ac_Role_ID
            AND cw.Office_IDNO = @An_Office_IDNO
            AND cw.Effective_DATE <= @Ad_Run_DATE
            AND cw.Expire_DATE > @Ad_Run_DATE
            AND cw.EndValidity_DATE = @Ld_High_DATE
            -- High Profile Case then Case Restriction Manager Role
            AND ((@Ln_HighProfile_NUMB >= 1
                  AND EXISTS (SELECT 1
                                FROM USRL_Y1 z
                               WHERE z.Worker_ID = cw.Worker_ID
                                 AND z.Office_IDNO = cw.Office_IDNO
                                 AND z.Role_ID = @Lc_RoleRs001_ID 
                                 AND z.Effective_DATE <= @Ad_Run_DATE
                                 AND z.Expire_DATE > @Ad_Run_DATE
                                 AND z.EndValidity_DATE = @Ld_High_DATE))
                  OR (@Ln_HighProfile_NUMB = 0))
			-- Familial Case then worker should not be familiar with the case                  
            AND ((@Ln_Familial_NUMB = 0)
                  OR (@Ln_Familial_NUMB > 0
                      AND NOT EXISTS (SELECT 1
                                        FROM USRT_Y1 t
                                       WHERE t.Case_IDNO = @An_Case_IDNO
                                         AND t.Familial_INDC = @Lc_Yes_INDC
                                         AND t.Worker_ID = cw.Worker_ID
                                         AND t.EndValidity_DATE = @Ld_High_DATE)));
        END
      END
      -- If Signed On Worker Is Batch
     ELSE
      BEGIN
       SET @Ls_Sql_TEXT = 'SELECT WORKER THAT HAS THE ROLE FROM USRL_Y1 - 3';
       SET @Ls_Sqldata_TEXT = 'Worker_ID = ' + ISNULL(@Ac_Case_Worker_ID,'')+ ', Office_IDNO = ' + ISNULL(CAST( @An_Office_IDNO AS VARCHAR ),'')+ ', Role_ID = ' + ISNULL(@Ac_Role_ID,'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', Role_ID = ' + ISNULL(@Lc_RoleRs001_ID,'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', Familial_INDC = ' + ISNULL(@Lc_Yes_INDC,'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');
       
       SELECT @Ln_Usrl_Count_NUMB = COUNT(1)
         FROM USRL_Y1 ur
        WHERE ur.Worker_ID = @Ac_Case_Worker_ID
          AND ur.Office_IDNO = @An_Office_IDNO
          AND ur.Role_ID = @Ac_Role_ID
          AND ur.Effective_DATE <= @Ad_Run_DATE
          AND ur.Expire_DATE > @Ad_Run_DATE
          AND ur.EndValidity_DATE = @Ld_High_DATE
          -- High Profile Case then Case Restriction Manager Role
          AND ((@Ln_HighProfile_NUMB >= 1
                AND EXISTS (SELECT 1
                              FROM USRL_Y1 z
                             WHERE z.Worker_ID = ur.Worker_ID
                               AND z.Office_IDNO = ur.Office_IDNO
                               AND z.Role_ID = @Lc_RoleRs001_ID 
                               AND z.Effective_DATE <= @Ad_Run_DATE
                               AND z.Expire_DATE > @Ad_Run_DATE
                               AND z.EndValidity_DATE = @Ld_High_DATE))
                OR (@Ln_HighProfile_NUMB = 0))
          -- Familial Case then worker should not be familiar with the case
          AND ((@Ln_Familial_NUMB = 0)
                OR (@Ln_Familial_NUMB > 0
                    AND NOT EXISTS (SELECT 1
                                      FROM USRT_Y1 t
                                     WHERE t.Case_IDNO = @An_Case_IDNO
                                       AND t.Familial_INDC = @Lc_Yes_INDC
                                       AND t.Worker_ID = ur.Worker_ID
                                       AND t.EndValidity_DATE = @Ld_High_DATE)));
       /* Case Worker has the specified Role in the Case County */
       IF @Ln_Usrl_Count_NUMB != 0
        BEGIN
         SET @Ac_Worker_ID = @Ac_Case_Worker_ID;
        END
      END
    END
   /* Case Worker does not have the specified Role in the Case County 
      and no worker has been assigned in CWRK_Y1 for this case and specified Role in the Case County 
   */
   IF (@Ac_Worker_ID IS NULL
        OR @Ac_Worker_ID = '')
    BEGIN
    
     -- Get The number of workers with the specified role in the case county
     SET @Ls_Sql_TEXT = 'SELECT THE COUNT FROM  USRL_Y1 - 2';
     SET @Ls_Sqldata_TEXT = 'Office_IDNO = ' + ISNULL(CAST( @An_Office_IDNO AS VARCHAR ),'')+ ', Role_ID = ' + ISNULL(@Ac_Role_ID,'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');
     
     SELECT @Ln_RoleWorkers_Usrl_Count_NUMB = COUNT(1)
       FROM USRL_Y1 ur
      WHERE ur.Office_IDNO = @An_Office_IDNO
        AND ur.Role_ID = @Ac_Role_ID
        AND ur.Effective_DATE <= @Ad_Run_DATE
        AND ur.Expire_DATE > @Ad_Run_DATE
        AND ur.EndValidity_DATE = @Ld_High_DATE;
     -- Get The number of workers without alpha assignment with the specified role in the case county
     SET @Ls_Sql_TEXT = 'SELECT THE COUNT FROM  USRL_Y1 - 2';
     SET @Ls_Sqldata_TEXT = 'Office_IDNO = ' + ISNULL(CAST( @An_Office_IDNO AS VARCHAR ),'')+ ', Role_ID = ' + ISNULL(@Ac_Role_ID,'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', AlphaRangeFrom_CODE = ' + ISNULL('','')+ ', AlphaRangeTo_CODE = ' + ISNULL('','');
     
     SELECT @Ln_NotAlphaAssigned_Usrl_Count_NUMB = COUNT(1)
       FROM USRL_Y1 ur
      WHERE ur.Office_IDNO = @An_Office_IDNO
        AND ur.Role_ID = @Ac_Role_ID
        AND ur.Effective_DATE <= @Ad_Run_DATE
        AND ur.Expire_DATE > @Ad_Run_DATE
        AND ur.EndValidity_DATE = @Ld_High_DATE
        AND ur.AlphaRangeFrom_CODE = ''
        AND ur.AlphaRangeTo_CODE = '';

	 -- If few workers with the specified role in the case county are alpha assigned (Not all workers alpha assigned)
     IF @Ln_RoleWorkers_Usrl_Count_NUMB != @Ln_NotAlphaAssigned_Usrl_Count_NUMB
      BEGIN
       -- Get the number of Putative Fathers in a case
       SET @Ls_Sql_TEXT = 'SELECT THE COUNT FROM CMEM_Y1 - 1';
       SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', CaseMemberStatus_CODE = ' + ISNULL(@Lc_CaseMemberStatusA_CODE,'');
       
       SELECT @Ln_CasePf_Count_NUMB = COUNT(1)
         FROM CMEM_Y1 cm
        WHERE cm.Case_IDNO = @An_Case_IDNO
          AND cm.CaseRelationship_CODE IN (@Lc_CaseRelationshipA_CODE, @Lc_CaseRelationshipP_CODE)
          AND cm.CaseMemberStatus_CODE = @Lc_CaseMemberStatusA_CODE;
       -- Get the number of Un-identified Putative Fathers in a case
       IF @Ln_CasePf_Count_NUMB = 1
        BEGIN
         SET @Ls_Sql_TEXT = 'SELECT THE COUNT FROM CMEM_Y1 - 2';
         SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', CaseMemberStatus_CODE = ' + ISNULL(@Lc_CaseMemberStatusA_CODE,'')+ ', MemberMci_IDNO = ' + ISNULL('999995','');
         
         SELECT @Ln_UnidentifiedPf_Count_NUMB = COUNT(1)
           FROM CMEM_Y1 cm
          WHERE cm.Case_IDNO = @An_Case_IDNO
            AND cm.CaseRelationship_CODE IN (@Lc_CaseRelationshipA_CODE, @Lc_CaseRelationshipP_CODE)
            AND cm.CaseMemberStatus_CODE = @Lc_CaseMemberStatusA_CODE
            AND cm.MemberMci_IDNO = 999995;
        END
       -- If Putative Fathers in a case are more than 1 OR atleast 1 Putative Fathers in a case is un-identified
       IF @Ln_CasePf_Count_NUMB > 1
           OR @Ln_UnidentifiedPf_Count_NUMB >= 1
        BEGIN
         -- Get the first 3 characters of the CP's Last Name
         SET @Ls_Sql_TEXT = 'SELECT THE COUNT FROM DEMO_Y1 - 1';
         SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', CaseRelationship_CODE = ' + ISNULL(@Lc_CaseRelationshipC_CODE,'')+ ', CaseMemberStatus_CODE = ' + ISNULL(@Lc_CaseMemberStatusA_CODE,'');
         
         SELECT @Lc_3CharOfLast_NAME = SUBSTRING(Last_NAME, 1, 3)
           FROM DEMO_Y1 dm
          WHERE dm.MemberMci_IDNO = (SELECT MemberMci_IDNO
                                       FROM CMEM_Y1 cm
                                      WHERE cm.Case_IDNO = @An_Case_IDNO
                                        AND cm.CaseRelationship_CODE = @Lc_CaseRelationshipC_CODE
                                        AND cm.CaseMemberStatus_CODE = @Lc_CaseMemberStatusA_CODE);
        END
       -- If only 1 Putative Father in a case AND no un-identified Putative Father in a case
       ELSE IF @Ln_CasePf_Count_NUMB = 1
          AND @Ln_UnidentifiedPf_Count_NUMB = 0
        BEGIN
         -- Get the first 3 characters of the NCP's Last Name
         SET @Ls_Sql_TEXT = 'SELECT THE COUNT FROM DEMO_Y1 - 1';
         SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', CaseMemberStatus_CODE = ' + ISNULL(@Lc_CaseMemberStatusA_CODE,'');
         
         SELECT @Lc_3CharOfLast_NAME = SUBSTRING(Last_NAME, 1, 3)
           FROM DEMO_Y1 dm
          WHERE dm.MemberMci_IDNO = (SELECT MemberMci_IDNO
                                       FROM CMEM_Y1 cm
                                      WHERE cm.Case_IDNO = @An_Case_IDNO
                                        AND cm.CaseRelationship_CODE IN (@Lc_CaseRelationshipA_CODE, @Lc_CaseRelationshipP_CODE)
                                        AND cm.CaseMemberStatus_CODE = @Lc_CaseMemberStatusA_CODE);
        END
      END

     SET @Ls_Sql_TEXT = 'SELECT WORKER THAT HAS THE ROLE FROM USRL_Y1, AND ASSIGN WORKER FOR THIS CASE IN CWRK_Y1';
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST(@An_Case_IDNO AS VARCHAR) + ', Case_Worker_ID = ' + @Ac_Case_Worker_ID + ', Office_IDNO = ' + CAST(@An_Office_IDNO AS VARCHAR) + ', Role_ID = ' + @Ac_Role_ID + ', Ac_Job_ID = ' + @Ac_Job_ID;

     IF @Ac_Job_ID != @Lc_JobRstr_ID
      BEGIN
       -- Get the Worker_ID as per Alpha Assignment
       SELECT @Ac_Worker_ID = b.Worker_ID,
              @Ac_Role_ID = b.Role_ID
         FROM (SELECT a.Worker_ID,
                      a.Role_ID,
                      a.CasesAssigned_QNTY,
                      ROW_NUMBER() OVER(ORDER BY a.CasesAssigned_QNTY ) rno
                 FROM (SELECT Worker_ID,
                              Role_ID,
                              ur.CasesAssigned_QNTY
                         FROM USRL_Y1 ur
                        WHERE ur.Office_IDNO = @An_Office_IDNO
                          AND ur.Role_ID = CASE
                                            WHEN (@Ac_Role_ID != ''
                                                  AND @Ac_Role_ID IS NOT NULL)
                                             THEN @Ac_Role_ID
                                            ELSE ur.Role_ID
                                           END
                          AND ur.Effective_DATE <= @Ad_Run_DATE
                          AND ur.Expire_DATE > @Ad_Run_DATE
                          AND ur.EndValidity_DATE = @Ld_High_DATE
                          AND ((@Ln_RoleWorkers_Usrl_Count_NUMB != @Ln_NotAlphaAssigned_Usrl_Count_NUMB
                                AND @Lc_3CharOfLast_NAME BETWEEN ur.AlphaRangeFrom_CODE AND ur.AlphaRangeTo_CODE)
                                OR @Ln_RoleWorkers_Usrl_Count_NUMB = @Ln_NotAlphaAssigned_Usrl_Count_NUMB)
                          -- High Profile Case then Case Restriction Manager Role
                          AND ((@Ln_HighProfile_NUMB >= 1
                                AND EXISTS (SELECT 1
                                              FROM USRL_Y1 z
                                             WHERE z.Worker_ID = ur.Worker_ID
                                               AND z.Office_IDNO = ur.Office_IDNO
                                               AND z.Role_ID = @Lc_RoleRs001_ID 
                                               AND z.Effective_DATE <= @Ad_Run_DATE
                                               AND z.Expire_DATE > @Ad_Run_DATE
                                               AND z.EndValidity_DATE = @Ld_High_DATE))
                                OR (@Ln_HighProfile_NUMB = 0))
						  -- Familial Case then worker should not be familiar with the case
                          AND ((@Ln_Familial_NUMB = 0)
                                OR (@Ln_Familial_NUMB > 0
                                    AND NOT EXISTS (SELECT 1
                                                      FROM USRT_Y1 t
                                                     WHERE t.Case_IDNO = @An_Case_IDNO
                                                       AND t.Familial_INDC = @Lc_Yes_INDC
                                                       AND t.Worker_ID = ur.Worker_ID
                                                       AND t.EndValidity_DATE = @Ld_High_DATE)))) AS a) AS b
        WHERE b.rno = 1;
        
        IF (@Ac_Worker_ID IS NULL
            OR @Ac_Worker_ID = '')
        BEGIN
         SET @Ls_Sql_TEXT = 'ASSIGN THE WORKER IF IT IS NULL OR SPACES - 1';
         SET @Ls_Sqldata_TEXT = 'rno = ' + ISNULL('1','');
         
         SELECT @Ac_Worker_ID = b.Worker_ID,
                @Ac_Role_ID = b.Role_ID
           FROM (SELECT a.Worker_ID,
                        a.Role_ID,
                        a.CasesAssigned_QNTY,
                        ROW_NUMBER() OVER(ORDER BY a.CasesAssigned_QNTY ) rno
                   FROM (SELECT Worker_ID,
                                Role_ID,
                                ur.CasesAssigned_QNTY
                           FROM USRL_Y1 ur
                          WHERE ur.Office_IDNO = @An_Office_IDNO
                            AND ur.Role_ID = CASE
                                              WHEN (@Ac_Role_ID != ''
                                                    AND @Ac_Role_ID IS NOT NULL)
                                               THEN @Ac_Role_ID
                                              ELSE ur.Role_ID
                                             END
                            AND ur.Effective_DATE <= @Ad_Run_DATE
                            AND ur.Expire_DATE > @Ad_Run_DATE
                            AND ur.EndValidity_DATE = @Ld_High_DATE
                          -- High Profile Case then Case Restriction Manager Role
                            AND ((@Ln_HighProfile_NUMB >= 1
                                  AND EXISTS (SELECT 1
                                                FROM USRL_Y1 z
                                               WHERE z.Worker_ID = ur.Worker_ID
                                                 AND z.Office_IDNO = ur.Office_IDNO
                                                 AND z.Role_ID = @Lc_RoleRs001_ID
                                                 AND z.Effective_DATE <= @Ad_Run_DATE
                                                 AND z.Expire_DATE > @Ad_Run_DATE
                                                 AND z.EndValidity_DATE = @Ld_High_DATE))
                                  OR (@Ln_HighProfile_NUMB = 0))
						  -- Familial Case then worker should not be familiar with the case
                            AND ((@Ln_Familial_NUMB = 0)
                                  OR (@Ln_Familial_NUMB > 0
                                      AND NOT EXISTS (SELECT 1
                                                        FROM USRT_Y1 t
                                                       WHERE t.Case_IDNO = @An_Case_IDNO
                                                         AND t.Familial_INDC = @Lc_Yes_INDC
                                                         AND t.Worker_ID = ur.Worker_ID
                                                         AND t.EndValidity_DATE = @Ld_High_DATE)))) AS a) AS b
          WHERE b.rno = 1;
        END
        
       -- If Primary Role, and if no worker found for the primary role then look for RP004 (Child Support Supervisor) role
       IF @Ac_Role_ID IN (SELECT Role_ID
                            FROM #PrimaryRole_P1)
        BEGIN
         IF (@Ac_Worker_ID IS NULL
              OR @Ac_Worker_ID = '')
          BEGIN
           -- If No worker ID found for the given role, then Get the Worker_ID as per Alpha Assignment for RP004 (Child Support Supervisor)
           SET @Ls_Sql_TEXT = 'ASSIGN THE WORKER IF IT IS NULL OR SPACES - 2';
           SET @Ls_Sqldata_TEXT = 'rno = ' + ISNULL('1','');
           
           SELECT @Ac_Worker_ID = b.Worker_ID,
                  @Ac_Role_ID = b.Role_ID
             FROM (SELECT a.Worker_ID,
                          a.Role_ID,
                          a.CasesAssigned_QNTY,
                          ROW_NUMBER() OVER(ORDER BY a.CasesAssigned_QNTY ) rno
                     FROM (SELECT Worker_ID,
                                  Role_ID,
                                  ur.CasesAssigned_QNTY
                             FROM USRL_Y1 ur
                            WHERE ur.Office_IDNO = @An_Office_IDNO
                              AND ur.Role_ID = @Lc_RoleRp004_ID
                              AND ur.Effective_DATE <= @Ad_Run_DATE
                              AND ur.Expire_DATE > @Ad_Run_DATE
                              AND ur.EndValidity_DATE = @Ld_High_DATE
                              AND ((@Ln_RoleWorkers_Usrl_Count_NUMB != @Ln_NotAlphaAssigned_Usrl_Count_NUMB
                                    AND @Lc_3CharOfLast_NAME BETWEEN ur.AlphaRangeFrom_CODE AND ur.AlphaRangeTo_CODE)
                                    OR @Ln_RoleWorkers_Usrl_Count_NUMB = @Ln_NotAlphaAssigned_Usrl_Count_NUMB)
                          -- High Profile Case then Case Restriction Manager Role
                              AND ((@Ln_HighProfile_NUMB >= 1
                                    AND EXISTS (SELECT 1
                                                  FROM USRL_Y1 z
                                                 WHERE z.Worker_ID = ur.Worker_ID
                                                   AND z.Office_IDNO = ur.Office_IDNO
                                                   AND z.Role_ID = @Lc_RoleRs001_ID 
                                                   AND z.Effective_DATE <= @Ad_Run_DATE
                                                   AND z.Expire_DATE > @Ad_Run_DATE
                                                   AND z.EndValidity_DATE = @Ld_High_DATE))
                                    OR (@Ln_HighProfile_NUMB = 0))
						  -- Familial Case then worker should not be familiar with the case
                              AND ((@Ln_Familial_NUMB = 0)
                                    OR (@Ln_Familial_NUMB > 0
                                        AND NOT EXISTS (SELECT 1
                                                          FROM USRT_Y1 t
                                                         WHERE t.Case_IDNO = @An_Case_IDNO
                                                           AND t.Familial_INDC = @Lc_Yes_INDC
                                                           AND t.Worker_ID = ur.Worker_ID
                                                           AND t.EndValidity_DATE = @Ld_High_DATE)))) AS a) AS b
            WHERE b.rno = 1;
          END

         IF (@Ac_Worker_ID IS NULL
              OR @Ac_Worker_ID = '')
          BEGIN
           -- If No worker ID found for the given role, then Get the Worker_ID without Alpha Assignment for RP004 (Child Support Supervisor)
           SET @Ls_Sql_TEXT = 'ASSIGN THE WORKER IF IT IS NULL OR SPACES - 3';
           SET @Ls_Sqldata_TEXT = 'rno = ' + ISNULL('1','');
           
           SELECT @Ac_Worker_ID = b.Worker_ID,
                  @Ac_Role_ID = b.Role_ID
             FROM (SELECT a.Worker_ID,
                          a.Role_ID,
                          a.CasesAssigned_QNTY,
                          ROW_NUMBER() OVER(ORDER BY a.CasesAssigned_QNTY ) rno
                     FROM (SELECT Worker_ID,
                                  Role_ID,
                                  ur.CasesAssigned_QNTY
                             FROM USRL_Y1 ur
                            WHERE ur.Office_IDNO = @An_Office_IDNO
                              AND ur.Role_ID = @Lc_RoleRp004_ID
                              AND ur.Effective_DATE <= @Ad_Run_DATE
                              AND ur.Expire_DATE > @Ad_Run_DATE
                              AND ur.EndValidity_DATE = @Ld_High_DATE
                          -- High Profile Case then Case Restriction Manager Role
                              AND ((@Ln_HighProfile_NUMB >= 1
                                    AND EXISTS (SELECT 1
                                                  FROM USRL_Y1 z
                                                 WHERE z.Worker_ID = ur.Worker_ID
                                                   AND z.Office_IDNO = ur.Office_IDNO
                                                   AND z.Role_ID = @Lc_RoleRs001_ID 
                                                   AND z.Effective_DATE <= @Ad_Run_DATE
                                                   AND z.Expire_DATE > @Ad_Run_DATE
                                                   AND z.EndValidity_DATE = @Ld_High_DATE))
                                    OR (@Ln_HighProfile_NUMB = 0))
						  -- Familial Case then worker should not be familiar with the case
                              AND ((@Ln_Familial_NUMB = 0)
                                    OR (@Ln_Familial_NUMB > 0
                                        AND NOT EXISTS (SELECT 1
                                                          FROM USRT_Y1 t
                                                         WHERE t.Case_IDNO = @An_Case_IDNO
                                                           AND t.Familial_INDC = @Lc_Yes_INDC
                                                           AND t.Worker_ID = ur.Worker_ID
                                                           AND t.EndValidity_DATE = @Ld_High_DATE)))) AS a) AS b
            WHERE b.rno = 1;
          END
        END

       IF (@Ac_Worker_ID IS NULL
            OR @Ac_Worker_ID = '')
        BEGIN
         SET @Ac_Msg_CODE = @Lc_ErrorE1354_CODE;
         SET @Ls_ErrorMessage_TEXT = 'Error IN ' + 'BATCH_COMMON$SP_GET_ALERT_WORKER_ID' + ' PROCEDURE' + '. Error DESC - ' + 'NO WORKER FOR THE GIVEN ROLE AND COUNTY AND ALSO NO WORKER ASSIGNED FOR CHILD SUPPORT SUPERVISOR ROLE IN THE GIVEN COUNTY. ' + @Ls_Sql_TEXT + '. Error List KEY - ' + @Ls_Sqldata_TEXT;

         RETURN;
        END
      END
     ELSE IF @Ac_Job_ID = @Lc_JobRstr_ID
      BEGIN
       SET @Ls_Sql_TEXT = 'ASSIGN THE WORKER ID FOR THE JOB ' + ISNULL(@Lc_JobRstr_ID, '');
       SET @Ls_Sqldata_TEXT = 'rno = ' + ISNULL('1','');
       
       SELECT @Ac_Worker_ID = b.Worker_ID,
              @Ac_Role_ID = b.Role_ID
         FROM (SELECT a.Worker_ID,
                      a.Role_ID,
                      a.CasesAssigned_QNTY,
                      ROW_NUMBER() OVER(ORDER BY a.CasesAssigned_QNTY ) rno
                 FROM (SELECT Worker_ID,
                              Role_ID,
                              ur.CasesAssigned_QNTY
                         FROM USRL_Y1 ur
                        WHERE ur.Office_IDNO = @An_Office_IDNO
                          AND (@Ln_HighProfile_NUMB = 0
                                OR ur.Role_ID = @Lc_RoleRs001_ID)
                          AND (@Ln_Familial_NUMB = 0
                                OR ur.Worker_ID NOT IN (SELECT t.Worker_ID
                                                          FROM USRT_Y1 t
                                                         WHERE t.Case_IDNO = @An_Case_IDNO
                                                           AND t.Familial_INDC = @Lc_Yes_INDC
                                                           AND t.EndValidity_DATE = @Ld_High_DATE))
                          AND (@Ln_HighProfile_NUMB > 0
                                OR @Ln_Familial_NUMB > 0)
                          AND ur.Effective_DATE <= @Ad_Run_DATE
                          AND ur.Expire_DATE > @Ad_Run_DATE
                          AND ur.EndValidity_DATE = @Ld_High_DATE
                          AND ((@Ln_RoleWorkers_Usrl_Count_NUMB != @Ln_NotAlphaAssigned_Usrl_Count_NUMB
                                AND @Lc_3CharOfLast_NAME BETWEEN ur.AlphaRangeFrom_CODE AND ur.AlphaRangeTo_CODE)
                                OR @Ln_RoleWorkers_Usrl_Count_NUMB = @Ln_NotAlphaAssigned_Usrl_Count_NUMB)
                          AND NOT EXISTS (SELECT Role_ID
                                            FROM CWRK_Y1 c
                                           WHERE c.EndValidity_DATE = @Ld_High_DATE
                                             AND @Ad_Run_DATE BETWEEN c.Effective_DATE AND c.Expire_DATE
                                             AND c.Case_IDNO = @An_Case_IDNO
                                             AND c.Office_IDNO = @An_Office_IDNO
                                             AND c.Worker_ID = @Ac_Case_Worker_ID
                                          EXCEPT
                                          SELECT Role_ID
                                            FROM USRL_Y1 b
                                           WHERE ur.Worker_ID = b.Worker_ID
                                             AND ur.Office_IDNO = b.Office_IDNO
                                             AND EndValidity_DATE = @Ld_High_DATE
                                             AND @Ad_Run_DATE BETWEEN Effective_DATE AND Expire_DATE
                                             AND b.Worker_ID <> @Ac_Case_Worker_ID)) AS a) AS b
        WHERE b.rno = 1;

       IF @Ac_Worker_ID = ''
           OR @Ac_Worker_ID IS NULL
        BEGIN
         SET @Ls_Sql_TEXT = 'ASSIGN THE WORKER IF IT IS NULL OR SPACES - 4';
         SET @Ls_Sqldata_TEXT = 'rno = ' + ISNULL('1','');
         
         SELECT @Ac_Worker_ID = b.Worker_ID,
                @Ac_Role_ID = b.Role_ID
           FROM (SELECT a.Worker_ID,
                        a.Role_ID,
                        a.CasesAssigned_QNTY,
                        ROW_NUMBER() OVER(ORDER BY a.CasesAssigned_QNTY ) rno
                   FROM (SELECT Worker_ID,
                                Role_ID,
                                ur.CasesAssigned_QNTY
                           FROM USRL_Y1 ur
                          WHERE ur.Office_IDNO = @An_Office_IDNO
                            AND (@Ln_HighProfile_NUMB = 0
                                  OR ur.Role_ID = @Lc_RoleRs001_ID)
                            AND (@Ln_Familial_NUMB = 0
                                  OR ur.Worker_ID NOT IN (SELECT t.Worker_ID
                                                            FROM USRT_Y1 t
                                                           WHERE t.Case_IDNO = @An_Case_IDNO
                                                             AND t.Familial_INDC = @Lc_Yes_INDC
                                                             AND t.EndValidity_DATE = @Ld_High_DATE))
                            AND (@Ln_HighProfile_NUMB > 0
                                  OR @Ln_Familial_NUMB > 0)
                            AND ur.Effective_DATE <= @Ad_Run_DATE
                            AND ur.Expire_DATE > @Ad_Run_DATE
                            AND ur.EndValidity_DATE = @Ld_High_DATE
                            AND NOT EXISTS (SELECT Role_ID
                                              FROM CWRK_Y1 c
                                             WHERE c.EndValidity_DATE = @Ld_High_DATE
                                               AND @Ad_Run_DATE BETWEEN c.Effective_DATE AND c.Expire_DATE
                                               AND c.Case_IDNO = @An_Case_IDNO
                                               AND c.Office_IDNO = @An_Office_IDNO
                                               AND c.Worker_ID = @Ac_Case_Worker_ID
                                            EXCEPT
                                            SELECT Role_ID
                                              FROM USRL_Y1 b
                                             WHERE ur.Worker_ID = b.Worker_ID
                                               AND ur.Office_IDNO = b.Office_IDNO
                                               AND EndValidity_DATE = @Ld_High_DATE
                                               AND @Ad_Run_DATE BETWEEN Effective_DATE AND Expire_DATE
                                               AND b.Worker_ID <> @Ac_Case_Worker_ID)) AS a) AS b
          WHERE b.rno = 1;
        END

       IF @Ac_Worker_ID = ''
           OR @Ac_Worker_ID IS NULL
        BEGIN
         SET @Ac_Msg_CODE = @Lc_ErrorE1216_CODE;
         SET @Ls_ErrorMessage_TEXT = 'Error IN ' + 'BATCH_COMMON$SP_GET_ALERT_WORKER_ID' + ' PROCEDURE' + ', Error DESC = ' + 'CASE IS NEITHER RESTRICTED NOR FAMILIAL. ' + @Ls_Sql_TEXT + ', Error List KEY - ' + @Ls_Sqldata_TEXT;

         IF @Ln_HighProfile_NUMB >= 1
            AND @Ln_Familial_NUMB >= 1
          BEGIN
           SET @Ls_ErrorMessage_TEXT = 'Error IN ' + 'BATCH_COMMON$SP_GET_ALERT_WORKER_ID' + ' PROCEDURE' + '. Error DESC  ' + ', NO WORKER FOR FAMILIAL CASE AND HIGHPROFILE ROLE. ' + @Ls_Sql_TEXT + ', Error List KEY - ' + @Ls_Sqldata_TEXT;
          END
         ELSE IF @Ln_HighProfile_NUMB >= 1
          BEGIN
           SET @Ls_ErrorMessage_TEXT = 'Error IN ' + 'BATCH_COMMON$SP_GET_ALERT_WORKER_ID' + ' PROCEDURE' + ', Error DESC ' + 'NO WORKER FOR THE HIGHPROFILE ROLE. ' + @Ls_Sql_TEXT + ', Error List KEY - ' + @Ls_Sqldata_TEXT;
          END
         ELSE IF @Ln_Familial_NUMB >= 1
          BEGIN
           SET @Ls_ErrorMessage_TEXT = 'Error IN ' + 'BATCH_COMMON$SP_GET_ALERT_WORKER_ID' + ' PROCEDURE' + '. Error DESC  ' + ', NO WORKER FOR FAMILIAL CASE. ' + @Ls_Sql_TEXT + ', Error List KEY - ' + @Ls_Sqldata_TEXT;
          END

         RETURN;
        END
      END
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = '';
  END TRY

  BEGIN CATCH
   BEGIN
    SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
    SET @Li_Error_NUMB = ERROR_NUMBER ();
    SET @Li_ErrorLine_NUMB = ERROR_LINE ();
    
   IF @Li_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

    EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
     @As_Procedure_NAME        = @Ls_Procedure_NAME,
     @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
     @As_Sql_TEXT              = @Ls_Sql_TEXT,
     @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
     @An_Error_NUMB            = @Li_Error_NUMB,
     @An_ErrorLine_NUMB        = @Li_ErrorLine_NUMB,
     @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
   END
  END CATCH
 END


GO
