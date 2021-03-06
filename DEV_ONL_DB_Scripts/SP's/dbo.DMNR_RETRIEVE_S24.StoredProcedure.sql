/****** Object:  StoredProcedure [dbo].[DMNR_RETRIEVE_S24]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DMNR_RETRIEVE_S24]  
(
	@Ac_Worker_ID              		CHAR(30),
	@An_Case_IDNO              		NUMERIC(6, 0),
    @Ac_File_ID                		CHAR(15),
    @An_Office_IDNO            		NUMERIC(3),
    @Ad_From_DATE              		DATE,
    @Ad_To_DATE                		DATE,
    @Ac_DaysOverdue_QNTY       		CHAR(3),
    @Ac_Category_CODE          		CHAR(2),
	@Ac_SubCategory_CODE       		CHAR(4),     
    @Ac_ActivityMinor_CODE     		CHAR(5),
	@Ac_OrderOfDisplay_TEXT			CHAR(4),
	@Ac_Status_CODE					CHAR(2),
	@Ac_TypeCase_CODE				CHAR(1),
	@Ac_RespondInit_CODE			CHAR(1),
    @An_County_IDNO					NUMERIC(3),
    @An_OfficeCentralExists_INDC	NUMERIC(2,0)
)
AS
/*
 *     PROCEDURE NAME    : DMNR_RETRIEVE_S24
 *     DESCRIPTION       : Retrieve the Due Date on which the Minor Activity is expected to be updated for a Sub System for a Worker ID
							 to whom the Activity has been Delegated in an Ascending Order.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 02-AUG-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
BEGIN
	DECLARE
		@Lc_ActionAlertActive_CODE				CHAR(1) = 'A',
		@Lc_StatusAssigned_CODE					CHAR(2) = 'AS',
        @Lc_StatusSupervisorApproval_CODE		CHAR(2) = 'SA',
        @Lc_StatusActive_CODE					CHAR(2) = 'AC',
		@Lc_StatusStart_CODE					CHAR(4) = 'STRT',
		@Lc_Space_TEXT							CHAR(1) = ' ',
		@Lc_Empty_TEXT							CHAR(1) = '',
		@Ld_Current_DATE						DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
		@Ld_High_DATE							DATE = '12/31/9999';
		
	DECLARE		
		@Ls_OuterSelect_TEXT					VARCHAR(MAX) = ' ',
		@Ls_ActiveSelectWorker_TEXT				VARCHAR(MAX) = ' ',
		@Ls_AssignedSelectDmnr_TEXT				VARCHAR(MAX) = ' ',
		@Ls_SupervisorAssignedSelectDmnr_TEXT	VARCHAR(MAX) = ' ',
		@Ls_WhereAppend_TEXT					VARCHAR(MAX) = ' ',
		@Ls_DaysOverdue_TEXT					VARCHAR(MAX) = ' ',
		@Ls_WhereOffice_TEXT					VARCHAR(MAX) = ' ',
		@Ls_OrderOfDisplay_TEXT					VARCHAR(100) = ' ',
		@Ls_Alias_TEXT							VARCHAR(100) = ' ',
		@Ls_GroupBy_TEXT						VARCHAR(100) = ' ',
		@Ls_DelegateWorker_TEXT					VARCHAR(100) = ' ',
		@Ls_Query_TEXT							NVARCHAR(MAX) = ' ',
		 @Ls_ParameterDefination_TEXT           NVARCHAR(MAX) = ' ';

SET @Ls_ParameterDefination_TEXT =   
    N'@Ac_Worker_ID              		CHAR(30),
	@An_Case_IDNO              		NUMERIC(6, 0),
    @Ac_File_ID                		CHAR(15),
    @An_Office_IDNO            		NUMERIC(3),
    @Ad_From_DATE              		DATE,
    @Ad_To_DATE                		DATE,
    @Ac_DaysOverdue_QNTY       		CHAR(3),
    @Ac_Category_CODE          		CHAR(2),
	@Ac_SubCategory_CODE       		CHAR(4),     
    @Ac_ActivityMinor_CODE     		CHAR(5),
	@Ac_OrderOfDisplay_TEXT			CHAR(4),
	@Ac_Status_CODE					CHAR(2),
	@Ac_TypeCase_CODE				CHAR(1),
	@Ac_RespondInit_CODE			CHAR(1),
    @An_County_IDNO					NUMERIC(3),
    @An_OfficeCentralExists_INDC	NUMERIC(2,0),
    @Lc_ActionAlertActive_CODE		CHAR(1),
    @Lc_StatusStart_CODE			CHAR(4),
    @Lc_Space_TEXT					CHAR(1),
    @Ld_Current_DATE				DATE,
    @Ld_High_DATE					DATE,
    @Ls_DaysOverdue_TEXT			VARCHAR(MAX)';  
	
	IF @Ac_OrderOfDisplay_TEXT IS NOT NULL
	BEGIN
		SET @Ls_OrderOfDisplay_TEXT = ' ORDER BY A.Due_DATE ' + @Ac_OrderOfDisplay_TEXT;
	END
	ELSE
	BEGIN
		SET @Ls_OrderOfDisplay_TEXT = ' ORDER BY A.Due_DATE ';
	END

	SET @Ls_OuterSelect_TEXT =
		'SELECT 
			J.Subsystem_CODE,

			SUM(
				CASE 
				WHEN J.DaysOverdue_QNTY = 1 THEN 1
				ELSE 0
				END) AS One_NUMB, 
			SUM(
				CASE 
				WHEN J.DaysOverdue_QNTY > 1 AND J.DaysOverdue_QNTY <= 10 THEN 1
				ELSE 0
				END) AS Ten_NUMB, 
			SUM(
				CASE 
				WHEN J.DaysOverdue_QNTY > 10 AND J.DaysOverdue_QNTY <= 30 THEN 1
				ELSE 0
            END) AS Thirty_NUMB, 
			SUM(
				CASE 
				WHEN J.DaysOverdue_QNTY > 30 AND J.DaysOverdue_QNTY <= 60 THEN 1
				ELSE 0
            END) AS Sixty_NUMB, 
			SUM(
				CASE 
				WHEN J.DaysOverdue_QNTY > 60 THEN 1
				ELSE 0
            END) AS AboveSixty_NUMB, 
			 
			J.RowCount_NUMB
		FROM 
			(
				SELECT 
				   Z.DaysOverdue_QNTY, 
				   Z.Subsystem_CODE, 
				   Z.ActivityMajor_CODE, 
				   Z.ORD_ROWNUM AS rnm, 
				   Z.RowCount_NUMB
				FROM 
				   (
					  SELECT
						 A.DaysOverdue_QNTY,
						 A.Subsystem_CODE,
						 A.ActivityMajor_CODE,
						 COUNT(1) OVER() AS RowCount_NUMB, 
						 ROW_NUMBER() OVER( ' + @Ls_OrderOfDisplay_TEXT + ') AS ORD_ROWNUM
					  FROM 
						 (';

	SET @Ls_ActiveSelectWorker_TEXT = 
		'SELECT 
		    D.ActivityMinor_CODE, 
		    D.Case_IDNO,
		    
		    CASE 
				WHEN DATEDIFF(dd, D.Due_DATE, ''' + CONVERT(VARCHAR(10), @Ld_Current_DATE) + ''') < 0 THEN NULL
				WHEN DATEDIFF(dd, D.Due_DATE, ''' + CONVERT(VARCHAR(10), @Ld_Current_DATE) + ''') = 0 THEN 0
				ELSE DATEDIFF(dd, D.Due_DATE, ''' + CONVERT(VARCHAR(10), @Ld_Current_DATE) + ''')
			END AS DaysOverdue_QNTY,
		    
		    D.Subsystem_CODE, 
		    D.ActivityMajor_CODE, 
		    D.Due_DATE
		 FROM 
		    DMNR_Y1 D,
		    ACRL_Y1 A,
		    AMNR_Y1 M,
		    CASE_Y1 C,
		    USRL_Y1 U
		 WHERE 
			  @Ac_Worker_ID   IN ( U.Worker_ID, U.WorkerSub_ID ) AND
			U.Office_IDNO =    CONVERT(VARCHAR(3), @An_Office_IDNO)   AND 
			U.Effective_DATE <= CONVERT(VARCHAR(10), @Ld_Current_DATE, 111) AND 
			U.Expire_DATE >= CONVERT(VARCHAR(10), @Ld_Current_DATE, 111)  AND 
			U.EndValidity_DATE =  CONVERT(VARCHAR(10), @Ld_High_DATE, 111)  AND
			U.Role_ID = A.Role_ID AND
			A.EndValidity_DATE = CONVERT(VARCHAR(10), @Ld_High_DATE, 111)  AND
			M.ActionAlert_CODE =  @Lc_ActionAlertActive_CODE  AND 
			M.EndValidity_DATE =  CONVERT(VARCHAR(10), @Ld_High_DATE, 111) AND
			M.ActivityMinor_CODE = A.ActivityMinor_CODE AND 
			A.Category_CODE = D.Subsystem_CODE AND
			A.SubCategory_CODE = D.ActivityMajor_CODE AND
			A.ActivityMinor_CODE = D.ActivityMinor_CODE AND
			C.Case_IDNO = D.Case_IDNO AND
			D.AlertPrior_DATE <= CONVERT(VARCHAR(10), @Ld_Current_DATE, 111)  AND 
			D.Status_DATE = CONVERT(VARCHAR(10), @Ld_High_DATE, 111)  AND
			D.Status_CODE =  @Lc_StatusStart_CODE ';
				
	SET @Ls_AssignedSelectDmnr_TEXT = 
		'SELECT 
		    D.ActivityMinor_CODE, 
		    D.Case_IDNO,
		    
		    CASE 
				WHEN DATEDIFF(dd, d.Due_DATE, ''' + CONVERT(VARCHAR(10), @Ld_Current_DATE) + ''') < 0 THEN NULL
				WHEN DATEDIFF(dd, d.Due_DATE, ''' + CONVERT(VARCHAR(10), @Ld_Current_DATE) + ''') = 0 THEN 0
				ELSE DATEDIFF(dd, D.Due_DATE, ''' + CONVERT(VARCHAR(10), @Ld_Current_DATE) + ''')
			END AS DaysOverdue_QNTY,
		    
		    D.Subsystem_CODE, 
		    D.ActivityMajor_CODE, 
		    D.Due_DATE
		FROM 
		    DMNR_Y1 D,
		    AMNR_Y1 M,
		    CASE_Y1 C
		WHERE
			D.WorkerDelegate_ID IN 
    	    (
				SELECT  @Ac_Worker_ID 
					UNION ALL
				SELECT U.Worker_ID
				FROM USRL_Y1 U
				WHERE 
					U.WorkerSub_ID =   @Ac_Worker_ID   AND 
					U.Office_IDNO =  CONVERT(VARCHAR(3), @An_Office_IDNO)  AND 
					U.Effective_DATE <=  CONVERT(VARCHAR(10), @Ld_Current_DATE, 111)  AND 
					U.Expire_DATE >=  CONVERT(VARCHAR(10), @Ld_Current_DATE, 111) AND 
					U.EndValidity_DATE = CONVERT(VARCHAR(10), @Ld_High_DATE, 111) 
			) AND
			D.AlertPrior_DATE <=  CONVERT(VARCHAR(10), @Ld_Current_DATE, 111) AND
			D.Status_DATE =CONVERT(VARCHAR(10), @Ld_High_DATE, 111)  AND
			D.Status_CODE = @Lc_StatusStart_CODE  AND
			D.ActivityMinor_CODE = M.ActivityMinor_CODE AND
			M.ActionAlert_CODE = @Lc_ActionAlertActive_CODE  AND
			M.EndValidity_DATE =  CONVERT(VARCHAR(10), @Ld_High_DATE, 111) AND
			C.Case_IDNO = D.Case_IDNO';
	
	SET @Ls_SupervisorAssignedSelectDmnr_TEXT = 
		'SELECT 
		    D.ActivityMinor_CODE, 
		    D.Case_IDNO,
		    
		    CASE 
				WHEN DATEDIFF(dd, d.Due_DATE, ''' + CONVERT(VARCHAR(10), @Ld_Current_DATE) + ''') < 0 THEN NULL
				WHEN DATEDIFF(dd, d.Due_DATE, ''' + CONVERT(VARCHAR(10), @Ld_Current_DATE) + ''') = 0 THEN 0
				ELSE DATEDIFF(dd, D.Due_DATE, ''' + CONVERT(VARCHAR(10), @Ld_Current_DATE) + ''')
			END AS DaysOverdue_QNTY,
		    
		    D.Subsystem_CODE, 
		    D.ActivityMajor_CODE, 
		    D.Due_DATE
		FROM 
		    DMNR_Y1 D,
		    AMNR_Y1 M,
		    CASE_Y1 C
		WHERE
			D.WorkerDelegate_ID IN 
    	    (
				SELECT U.Worker_ID
				FROM USRL_Y1 U
				WHERE 
					U.Supervisor_ID =   @Ac_Worker_ID   AND 
					U.Effective_DATE <=  CONVERT(VARCHAR(10), @Ld_Current_DATE, 111)  AND 
					U.Expire_DATE >=  CONVERT(VARCHAR(10), @Ld_Current_DATE, 111)  AND 
					U.EndValidity_DATE = CONVERT(VARCHAR(10), @Ld_High_DATE, 111)
			) AND
			D.AlertPrior_DATE <=  CONVERT(VARCHAR(10), @Ld_Current_DATE, 111)  AND
			D.Status_DATE =  CONVERT(VARCHAR(10), @Ld_High_DATE, 111)  AND
			D.Status_CODE =  @Lc_StatusStart_CODE  AND
			D.ActivityMinor_CODE = M.ActivityMinor_CODE AND
			M.ActionAlert_CODE =  @Lc_ActionAlertActive_CODE  AND
			M.EndValidity_DATE = CONVERT(VARCHAR(10), @Ld_High_DATE, 111)  AND
			C.Case_IDNO = D.Case_IDNO';

	IF @An_Office_IDNO IS NOT NULL
	BEGIN		
		IF @An_OfficeCentralExists_INDC != 1
		BEGIN
			IF @Ac_Status_CODE IN(@Lc_StatusAssigned_CODE, @Lc_StatusSupervisorApproval_CODE)
			BEGIN
				SET @Ls_WhereOffice_TEXT = 'AND C.County_IDNO =   @An_County_IDNO  ';
			END
			ELSE
			BEGIN
				SET @Ls_WhereOffice_TEXT = 'AND C.County_IDNO =   @An_County_IDNO AND
										C.Office_IDNO =   @An_Office_IDNO';
			END
		END
	END
	
	IF @An_Case_IDNO IS NOT NULL
	BEGIN
		SET @Ls_WhereAppend_TEXT =  ' AND D.Case_IDNO = @An_Case_IDNO ';
	END
	
	IF @Ac_File_ID IS NOT NULL OR @Ac_TypeCase_CODE IS NOT NULL OR @Ac_RespondInit_CODE IS NOT NULL
	BEGIN
		SET @Ls_WhereAppend_TEXT = @Ls_WhereAppend_TEXT + 
								' AND EXISTS (
												SELECT 1
												FROM CASE_Y1 C1
												WHERE 
													C1.Case_IDNO = D.Case_IDNO ';
		
		IF @Ac_File_ID IS NOT NULL
		BEGIN
			SET @Ls_WhereAppend_TEXT = @Ls_WhereAppend_TEXT + 
									' AND C1.File_ID =   @Ac_File_ID ';
		END
		
		IF @Ac_TypeCase_CODE IS NOT NULL
		BEGIN
			SET @Ls_WhereAppend_TEXT = @Ls_WhereAppend_TEXT + 
									' AND C1.TypeCase_CODE =   @Ac_TypeCase_CODE  ';
		END
		
		IF @Ac_RespondInit_CODE IS NOT NULL
		BEGIN
			SET @Ls_WhereAppend_TEXT = @Ls_WhereAppend_TEXT + 
									' AND C1.RespondInit_CODE =   @Ac_RespondInit_CODE ';
		END
		SET @Ls_WhereAppend_TEXT = @Ls_WhereAppend_TEXT + ' )';
	END
	
	IF @Ac_Category_CODE IS NOT NULL
	BEGIN
		SET @Ls_WhereAppend_TEXT = @Ls_WhereAppend_TEXT +
								' AND D.Subsystem_CODE =   @Ac_Category_CODE ';
	END
	
	IF @Ac_SubCategory_CODE IS NOT NULL
	BEGIN
		SET @Ls_WhereAppend_TEXT = @Ls_WhereAppend_TEXT +
								' AND D.ActivityMajor_CODE =  @Ac_SubCategory_CODE  ';
	END
	
	IF @Ac_ActivityMinor_CODE IS NOT NULL
	BEGIN
		SET @Ls_WhereAppend_TEXT = @Ls_WhereAppend_TEXT +
								' AND D.ActivityMinor_CODE =   @Ac_ActivityMinor_CODE  ';
	END
	
	IF @Ac_DaysOverdue_QNTY IS NOT NULL
	BEGIN
		IF @Ac_DaysOverdue_QNTY = '1' OR @Ac_DaysOverdue_QNTY = '01'
		BEGIN
			SET @Ls_DaysOverdue_TEXT = ' = 1 ';
		END
		ELSE IF @Ac_DaysOverdue_QNTY = '2' OR @Ac_DaysOverdue_QNTY = '02'
		BEGIN
			SET @Ls_DaysOverdue_TEXT = ' BETWEEN 2 AND 10 ';
		END
		ELSE IF @Ac_DaysOverdue_QNTY = '11'
		BEGIN
			SET @Ls_DaysOverdue_TEXT = ' BETWEEN 11 AND 30 ';
		END
		ELSE IF @Ac_DaysOverdue_QNTY = '30'
		BEGIN
			SET @Ls_DaysOverdue_TEXT = ' BETWEEN 31 AND 60 ';
		END
		ELSE IF @Ac_DaysOverdue_QNTY = '60'
		BEGIN
			SET @Ls_DaysOverdue_TEXT = ' > 60 ';
		END
		ELSE IF @Ac_DaysOverdue_QNTY = 'S'
		BEGIN
			SET @Ls_DaysOverdue_TEXT = ' >= 1 ';
		END
		ELSE
		BEGIN
			SET @Ls_DaysOverdue_TEXT = @Lc_Empty_TEXT;
		END
		
		SET @Ls_WhereAppend_TEXT = @Ls_WhereAppend_TEXT + 
								' AND DATEDIFF(dd, D.Due_DATE, CONVERT(VARCHAR(10), @Ld_Current_DATE) )'  + @Ls_DaysOverdue_TEXT;
	END
	
	SET @Ls_WhereAppend_TEXT = @Ls_WhereAppend_TEXT +
							' AND D.Entered_DATE BETWEEN   CONVERT(VARCHAR(10), @Ad_From_DATE, 111)  AND   CONVERT(VARCHAR(10), @Ad_To_DATE, 111)  ';
	
	SET @Ls_Alias_TEXT = ') A ) Z) J';
	SET @Ls_GroupBy_TEXT = ' GROUP BY J.Subsystem_CODE, J.RowCount_NUMB ';
	
	IF @Ac_Status_CODE = @Lc_StatusAssigned_CODE
	BEGIN
		SET @Ls_Query_TEXT = @Ls_OuterSelect_TEXT +
								@Ls_AssignedSelectDmnr_TEXT +
								@Ls_WhereAppend_TEXT + 
								@Ls_WhereOffice_TEXT + 
								@Ls_Alias_TEXT +
								@Ls_GroupBy_TEXT;
	END
	
	IF @Ac_Status_CODE = @Lc_StatusSupervisorApproval_CODE
	BEGIN
		SET @Ls_Query_TEXT = @Ls_OuterSelect_TEXT +
								@Ls_SupervisorAssignedSelectDmnr_TEXT +
								@Ls_WhereAppend_TEXT + 
								@Ls_WhereOffice_TEXT + 
								@Ls_Alias_TEXT +
								@Ls_GroupBy_TEXT;
	END
	
	IF @Ac_Status_CODE = @Lc_StatusActive_CODE
	BEGIN
		SET @Ls_DelegateWorker_TEXT = ' AND D.WorkerDelegate_ID = @Lc_Space_TEXT ';
		SET @Ls_Query_TEXT = @Ls_OuterSelect_TEXT +
								@Ls_ActiveSelectWorker_TEXT +
								@Ls_DelegateWorker_TEXT +
								@Ls_WhereAppend_TEXT +
								@Ls_WhereOffice_TEXT +
								@Ls_Alias_TEXT +
								@Ls_GroupBy_TEXT;
	END
 	
 	PRINT(@Ls_OuterSelect_TEXT);
 	PRINT(@Ls_AssignedSelectDmnr_TEXT);
 	PRINT(@Ls_WhereAppend_TEXT);
 	PRINT(@Ls_WhereOffice_TEXT);
 	PRINT(@Ls_Alias_TEXT);
 	PRINT(@Ls_GroupBy_TEXT );
 	
	 EXEC SP_EXECUTESQL  
  @Ls_Query_TEXT,  
  @Ls_ParameterDefination_TEXT,  
      @Ac_Worker_ID              		= @Ac_Worker_ID              	  ,
	@An_Case_IDNO              		=	@An_Case_IDNO              	  ,
    @Ac_File_ID                		= @Ac_File_ID                	  ,
    @An_Office_IDNO            		= @An_Office_IDNO            	  ,
    @Ad_From_DATE              		= @Ad_From_DATE              	  ,
    @Ad_To_DATE                		= @Ad_To_DATE                	  ,
    @Ac_DaysOverdue_QNTY       		= @Ac_DaysOverdue_QNTY       	  ,
    @Ac_Category_CODE          		= @Ac_Category_CODE          	  ,
	@Ac_SubCategory_CODE       		=	@Ac_SubCategory_CODE       	  ,
    @Ac_ActivityMinor_CODE     		= @Ac_ActivityMinor_CODE     	  ,
	@Ac_OrderOfDisplay_TEXT			=	@Ac_OrderOfDisplay_TEXT		  ,  
	@Ac_Status_CODE					=	@Ac_Status_CODE				  ,        
	@Ac_TypeCase_CODE				=	@Ac_TypeCase_CODE			  ,       
	@Ac_RespondInit_CODE			=	@Ac_RespondInit_CODE		  ,     
    @An_County_IDNO					= @An_County_IDNO				  ,        
    @An_OfficeCentralExists_INDC	= @An_OfficeCentralExists_INDC    ,
    @Lc_ActionAlertActive_CODE	=@Lc_ActionAlertActive_CODE,
    @Lc_StatusStart_CODE	=@Lc_StatusStart_CODE,
    @Lc_Space_TEXT		=@Lc_Space_TEXT,
    @Ld_Current_DATE	=@Ld_Current_DATE,
    @Ld_High_DATE	=@Ld_High_DATE,
    @Ls_DaysOverdue_TEXT=@Ls_DaysOverdue_TEXT;
	
END

GO
