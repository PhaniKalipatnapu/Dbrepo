/****** Object:  StoredProcedure [dbo].[BATCH_EST_INCOMING_FC_RTPR$SP_UPDATE_FSRT]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
------------------------------------------------------------------------------------------------------------------------
Procedure Name	     : BATCH_EST_INCOMING_FC_RTPR$SP_UPDATE_FSRT
Programmer Name		 : IMP Team
Description			 : The procedure update a family court service tracking information into the service tracking table. 
Frequency			 : Daily
Developed On		 : 10/17/2011
Called By			 : 
Called On			 : 
----------------------------------------------------------------------------------------------------------------------------------						   
Modified By			 : 
Modified On			 :
Version No			 : 1.0
------------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_EST_INCOMING_FC_RTPR$SP_UPDATE_FSRT]  
   @An_Case_IDNO				NUMERIC(6),
   @Ac_File_ID					CHAR(10),
   @An_MajorIntSeq_NUMB			NUMERIC(5, 0),
   @An_MinorIntSeq_NUMB			NUMERIC(5, 0),
   @An_Petition_IDNO			NUMERIC(7),
   @Ac_ServiceMethod_CODE		CHAR(1),
   @Ac_ServiceResult_CODE		CHAR(1),
   @Ac_ServiceFailureReason_CODE CHAR(1),
   @As_ServiceLine1_ADDR		VARCHAR(50),
   @As_ServiceLine2_ADDR		VARCHAR(50),
   @Ac_ServiceCity_ADDR			CHAR(28),
   @Ac_ServiceState_ADDR		CHAR(2),
   @Ac_ServiceZip_ADDR			CHAR(15),
   @As_ServiceNotes_TEXT		VARCHAR(1000),
   @Ad_Run_DATE					DATE,	
   @Ad_Service_DATE				DATE,
   @Ad_PetitionAction_DATE      DATE,
   @An_TransactionEventSeq_NUMB	NUMERIC(19),	
   @Ac_Msg_CODE					CHAR(1)		   OUTPUT,
   @As_DescriptionError_TEXT	VARCHAR(4000)  OUTPUT
    
AS 
    
   BEGIN
    SET NOCOUNT ON;
      
     DECLARE @Lc_StatusFailed_CODE		 CHAR(1)		= 'F',
             @Lc_StatusSuccess_CODE		 CHAR(1)		= 'S',
             @Lc_BatchRunUser_TEXT		 CHAR(30)		= 'BATCH',
             @Ls_Procedure_NAME			 VARCHAR(60)	= 'SP_INSERT_NOTE',
             @Ld_High_DATE				 DATE			= '12/31/9999';
	 DECLARE @Ln_Zero_NUMB				 NUMERIC(1)		= 0,
             @Ln_MinorIntSeq_NUMB		 NUMERIC(5,0)	= 0,
             @Ln_Error_NUMB				 NUMERIC(11)	= 0,
             @Ln_ErrorLine_NUMB			 NUMERIC(11)	= 0,
             @Li_RowCount_QNTY			 SMALLINT,
             @Lc_Space_TEXT				 CHAR(1)		= ' ',
             @Lc_Exception_CODE			 CHAR(1)		= '',
             @Ls_Sql_TEXT				 VARCHAR(100)	= '',
             @Ls_Sqldata_TEXT			 VARCHAR(1000)	= '',
             @Ls_DescriptionError_TEXT	 VARCHAR(4000)	= '',
             @Ls_ErrorMessage_TEXT		 VARCHAR(4000)	 = '',
             @Ld_ProcessServer_DATE		 DATE,
             @Ld_Start_DATE				 DATETIME2;

      BEGIN TRY

         -- Selecting the batch start time
        SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
        SET @Ac_Msg_CODE = ' ';
        SET @As_DescriptionError_TEXT = '';
        SET @Lc_Exception_CODE = '';

        SET @Ls_Sql_TEXT = @Lc_Space_TEXT;

        SET @Ls_Sqldata_TEXT = @Lc_Space_TEXT;
		 		 
        SET @Ls_Sql_TEXT		= 'SELECT FROM FSRT_Y1 TABLE ';
        SET @Ls_Sqldata_TEXT	= 'CASE IDNO = ' + CAST(@An_Case_IDNO AS VARCHAR) + ', FILE ID = ' + @Ac_File_ID + 
		 						 ', MAJOR INT SEQ NUMB = ' + CAST(@An_MajorIntSeq_NUMB AS VARCHAR); 
		SELECT TOP 1 
			@Ln_MinorIntSeq_NUMB		= f.MinorIntSeq_NUMB,
			@Ld_ProcessServer_DATE		= f.ProcessServer_DATE
		 FROM FSRT_Y1 f
		 WHERE f.Case_IDNO			= @An_Case_IDNO
		   AND f.File_ID			= @Ac_File_ID
		   AND f.MajorIntSeq_NUMB   = @An_MajorIntSeq_NUMB
		   AND f.Petition_IDNO		= @An_Petition_IDNO
		   AND f.EndValidity_DATE	= @Ld_High_DATE;
		 -- Check the table read fetches any records or not
   		SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   		IF @Li_Rowcount_QNTY	= @Ln_Zero_NUMB
   		 BEGIN
   			-- 310 Start
   			-- If no FSRT_y1 table entry, inert a new record into the FSRT_Y1 table and do not the write the record into BATE_Y1
   			--Insert a new record into the FSR_Y1 table with the servicing address into the servicing table 
		                  
			SET @Ls_Sql_TEXT		= 'INSERT INTO TABLE FSRT_Y1 '; 
			SET @Ls_Sqldata_TEXT	= 'CASE IDNO = ' + CAST(@An_Case_IDNO AS VARCHAR) + ', FILE ID = ' + @Ac_File_ID + 
		 						 ', MAJOR INT SEQ NUMB = ' + CAST(@An_MajorIntSeq_NUMB AS VARCHAR); 
			INSERT INTO FSRT_Y1( 
   				Case_IDNO,		
				File_ID,		
				MajorIntSEQ_NUMB,
				MinorIntSeq_NUMB,
				Petition_IDNO,
				ServiceMethod_CODE,
				ServiceResult_CODE,
				ServiceFailureReason_CODE,
				ProcessServer_DATE,
				Service_DATE,
				ServiceAttn_ADDR,
				ServiceLine1_ADDR,
				ServiceLine2_ADDR,
				ServiceCity_ADDR,
				ServiceState_ADDR,
				ServiceZip_ADDR,
				ServiceNotes_TEXT,
				BeginValidity_DATE,
				EndValidity_DATE,
				WorkerUpdate_ID,
				Update_DTTM,
				TransactionEventSeq_NUMB,
				ServiceCountry_ADDR)
			SELECT 
				@An_Case_IDNO AS Case_IDNO,
				@Ac_File_ID AS File_ID,
				@An_MajorIntSeq_NUMB AS MajorIntSEQ_NUMB,
				@An_MinorIntSeq_NUMB AS MinorIntSeq_NUMB,
				@An_Petition_IDNO AS Petition_IDNO,
				@Ac_ServiceMethod_CODE AS ServiceMethod_CODE,
				@Ac_ServiceResult_CODE AS ServiceResult_CODE,
				@Ac_ServiceFailureReason_CODE AS ServiceFailureReason_CODE,								
				@Ad_PetitionAction_DATE AS ProcessServer_DATE,
				@Ad_Service_DATE AS Service_DATE,
				@Lc_Space_TEXT AS ServiceAttn_ADDR,
				@As_ServiceLine1_ADDR AS ServiceLine1_ADDR,
				@As_ServiceLine2_ADDR AS ServiceLine2_ADDR,
				@Ac_ServiceCity_ADDR AS ServiceCity_ADDR,
				@Ac_ServiceState_ADDR AS ServiceState_ADDR,
				@Ac_ServiceZip_ADDR AS ServiceZip_ADDR,
				@As_ServiceNotes_TEXT AS ServiceNotes_TEXT,
				@Ad_Run_DATE AS BeginValidity_DATE,
				@Ld_High_DATE AS EndValidity_DATE,
				@Lc_BatchRunUser_TEXT AS WorkerUpdate_ID,
				@Ld_Start_DATE AS Update_DTTM, 
				@An_TransactionEventSeq_NUMB AS TransactionEventSeq_NUMB,
				@Lc_Space_TEXT AS ServiceCountry_ADDR;
			SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   			IF @Li_Rowcount_QNTY = @Ln_Zero_NUMB
   			 BEGIN 
   				SET @Ls_DescriptionError_TEXT = 'FSRT_Y1 INSERT FAILED ';
				RAISERROR(50001, 16, 1);
			 END
	
         END  
			-- 310 End 		 
		-- Logical update of current active record in FSRT_Y1
		ELSE
		 BEGIN
		  SET @Ls_Sql_TEXT		= 'UPDATE TABLE FSRT_Y1 '; 
		  SET @Ls_Sqldata_TEXT	= 'CASE IDNO = ' + CAST(@An_Case_IDNO AS VARCHAR) + ', FILE ID = ' + @Ac_File_ID + 
		 						 ', MAJOR INT SEQ NUMB = ' + CAST(@An_MajorIntSeq_NUMB AS VARCHAR); 
		  UPDATE FSRT_Y1
			SET EndValidity_DATE = @Ad_Run_DATE,
				Update_DTTM		 = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME() 
		   WHERE Case_IDNO			= @An_Case_IDNO
		   AND File_ID				= @Ac_File_ID
		   AND MajorIntSeq_NUMB		= @An_MajorIntSeq_NUMB
		   AND Petition_IDNO		= @An_Petition_IDNO
		   AND EndValidity_DATE		= @Ld_High_DATE;
         
          -- Check the table update updated any rows, if not raise error
   		  SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   		  IF @Li_Rowcount_QNTY	= @Ln_Zero_NUMB
   		   BEGIN
   			SET @Ls_DescriptionError_TEXT = 'FSRT_Y1 UPDATE FAILED ';
			RAISERROR(50001, 16, 1); 
		   END
		
		  --Insert a new record into the FSR_Y1 table with the servicing address into the servicing table 
		                  
          SET @Ls_Sql_TEXT		= 'INSERT INTO TABLE FSRT_Y1 '; 
		  SET @Ls_Sqldata_TEXT	= 'CASE IDNO = ' + CAST(@An_Case_IDNO AS VARCHAR) + ', FILE ID = ' + @Ac_File_ID + 
		 						 ', MAJOR INT SEQ NUMB = ' + CAST(@An_MajorIntSeq_NUMB AS VARCHAR); 
          INSERT INTO FSRT_Y1( 
   			Case_IDNO,		
			File_ID,		
			MajorIntSEQ_NUMB,
			MinorIntSeq_NUMB,
			Petition_IDNO,
			ServiceMethod_CODE,
			ServiceResult_CODE,
			ServiceFailureReason_CODE,
			ProcessServer_DATE,
			Service_DATE,
			ServiceAttn_ADDR,
			ServiceLine1_ADDR,
			ServiceLine2_ADDR,
			ServiceCity_ADDR,
			ServiceState_ADDR,
			ServiceZip_ADDR,
			ServiceNotes_TEXT,
			BeginValidity_DATE,
			EndValidity_DATE,
			WorkerUpdate_ID,
			Update_DTTM,
			TransactionEventSeq_NUMB,
			ServiceCountry_ADDR)
		  SELECT 
			@An_Case_IDNO AS Case_IDNO,
			@Ac_File_ID AS File_ID,
			@An_MajorIntSeq_NUMB AS MajorIntSEQ_NUMB,
			@Ln_MinorIntSeq_NUMB AS MinorIntSeq_NUMB,
			@An_Petition_IDNO AS Petition_IDNO,
			@Ac_ServiceMethod_CODE AS ServiceMethod_CODE,
			@Ac_ServiceResult_CODE AS ServiceResult_CODE,
			@Ac_ServiceFailureReason_CODE AS ServiceFailureReason_CODE,								
			@Ld_ProcessServer_DATE AS ProcessServer_DATE,
			@Ad_Service_DATE AS Service_DATE,
			@Lc_Space_TEXT AS ServiceAttn_ADDR,
			@As_ServiceLine1_ADDR AS ServiceLine1_ADDR,
			@As_ServiceLine2_ADDR AS ServiceLine2_ADDR,
			@Ac_ServiceCity_ADDR AS ServiceCity_ADDR,
			@Ac_ServiceState_ADDR AS ServiceState_ADDR,
			@Ac_ServiceZip_ADDR AS ServiceZip_ADDR,
			@As_ServiceNotes_TEXT AS ServiceNotes_TEXT,
			@Ad_Run_DATE AS BeginValidity_DATE,
			@Ld_High_DATE AS EndValidity_DATE,
			@Lc_BatchRunUser_TEXT AS WorkerUpdate_ID,
			@Ld_Start_DATE AS Update_DTTM, 
			@An_TransactionEventSeq_NUMB AS TransactionEventSeq_NUMB,
			@Lc_Space_TEXT AS ServiceCountry_ADDR;
		  SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   		  IF @Li_Rowcount_QNTY = @Ln_Zero_NUMB
   			BEGIN 
   				SET @Ls_DescriptionError_TEXT = 'FSRT_Y1 INSERT FAILED ';
				RAISERROR(50001, 16, 1);
			END
	
         END 
        SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;

        SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;   
	
      END TRY

      BEGIN CATCH
					
			--Set Error Description
            SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
            SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;
			SET @Ln_Error_NUMB = ERROR_NUMBER ();
		    SET @Ln_ErrorLine_NUMB = ERROR_LINE ();
		    IF @Ln_Error_NUMB <> 50001
		    
				BEGIN
					SET @Ls_ErrorMessage_TEXT =
                      SUBSTRING (ERROR_MESSAGE (), 1, 200);
				END
			EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION 
				@As_Procedure_NAME			= @Ls_Procedure_NAME,
                @As_ErrorMessage_TEXT		= @Ls_ErrorMessage_TEXT,
                @As_Sql_TEXT				= @Ls_Sql_TEXT,
                @As_Sqldata_TEXT			= @Ls_Sqldata_TEXT,
                @An_Error_NUMB				= @Ln_Error_NUMB,
                @An_ErrorLine_NUMB			= @Ln_ErrorLine_NUMB,
                @As_DescriptionError_TEXT	= @As_DescriptionError_TEXT OUTPUT; 
							
      END CATCH

   END

GO
