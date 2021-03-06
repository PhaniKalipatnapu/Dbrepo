/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_CNET$SP_GET_INFO_BLOCK_OPTS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICE_CNET$SP_GET_INFO_BLOCK_OPTS
Programmer Name	:	IMP Team.
Description		:	
Frequency		:	
Developed On	:	2/17/2012
Called By		:	
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_CNET$SP_GET_INFO_BLOCK_OPTS] 
(
   @Ac_IVDOutOfStateFips_CODE          CHAR(2),
   @An_TransHeader_IDNO                NUMERIC(12),
   @Ad_Transaction_DATE                DATE,
   @Ac_TransOtherState_INDC			   CHAR(1),    
   @Ac_Msg_CODE                        CHAR(5)		 OUTPUT,
   @As_DescriptionError_TEXT           VARCHAR(4000) OUTPUT
)
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE  @Lc_StatusSuccess_CODE  CHAR(1) = 'S',
           @Lc_StatusFailed_CODE   CHAR(1) = 'F',
           @Ls_Procedure_NAME      VARCHAR(100) = 'BATCH_GEN_NOTICE_CNET$SP_GET_INFO_BLOCK_OPTS',
           @Ld_High_DATE           DATE = '12/31/9999';
 
  DECLARE  @Li_RowCount_NUMB          INT = 0;
  DECLARE  @Ln_Message_IDNO           NUMERIC(12),
           @Lc_Info_CODE              CHAR(1),
           @Ls_InfoLine1_TEXT         VARCHAR(80) = '',
           @Ls_InfoLine2_TEXT         VARCHAR(80) = '',
           @Ls_InfoLine3_TEXT         VARCHAR(80) = '',
           @Ls_InfoLine4_TEXT         VARCHAR(80) = '',
           @Ls_InfoLine5_TEXT         VARCHAR(80) = '',
           @Ls_Sql_TEXT               VARCHAR(200),
           @Ls_InfoLine_TEXT          VARCHAR(400) = '',
           @Ls_Sqldata_TEXT           VARCHAR(1000),
           @Ls_DescriptionError_TEXT  VARCHAR(4000);

      BEGIN TRY
         SET @Ac_Msg_CODE = NULL;
         SET @As_DescriptionError_TEXT = NULL;
         SET @Ls_Sql_TEXT = 'SELECT CFOB_Y1';
         SET @Ls_Sqldata_TEXT = ' StateFips_CODE = '
								+ ISNULL (@Ac_IVDOutOfStateFips_CODE , '')
								+ ', TransHeader_IDNO = '
								+ ISNULL(CAST(@An_TransHeader_IDNO AS VARCHAR),'')
								+ ', Transaction_DATE = '
								+ ISNULL (CAST(@Ad_Transaction_DATE AS VARCHAR), '');

         IF (@Ac_TransOtherState_INDC = 'I')
            BEGIN
               
               SELECT @Ls_InfoLine1_TEXT = f.InfoLine1_TEXT,
                      @Ls_InfoLine2_TEXT = f.InfoLine2_TEXT,
                      @Ls_InfoLine3_TEXT = f.InfoLine3_TEXT,
                      @Ls_InfoLine4_TEXT = f.InfoLine4_TEXT,
                      @Ls_InfoLine5_TEXT = f.InfoLine5_TEXT
                 FROM CFOB_Y1 f
                WHERE f.TransHeader_IDNO = @An_TransHeader_IDNO
                      AND f.IVDOutOfStateFips_CODE =    @Ac_IVDOutOfStateFips_CODE
                      AND f.Transaction_DATE = @Ad_Transaction_DATE;

               SET @Ls_InfoLine_TEXT =
									@Ls_InfoLine1_TEXT
								  + ' '
								  + @Ls_InfoLine2_TEXT
								  + ' '
								  + @Ls_InfoLine3_TEXT
								  + ' '
								  + @Ls_InfoLine4_TEXT
								  + ' '
								  + @Ls_InfoLine5_TEXT;
            END;
         ELSE
            BEGIN
               SELECT @Ls_InfoLine_TEXT = SUBSTRING (A.DescriptionComments_TEXT, 1, 400)
                 FROM CSPR_Y1 A
                WHERE A.Request_IDNO = @An_TransHeader_IDNO
                      AND A.EndValidity_DATE = @Ld_High_DATE;
               SET @Li_RowCount_NUMB = @@ROWCOUNT;

               IF (@Li_RowCount_NUMB = 0)
                  BEGIN
                     SELECT @Ln_Message_IDNO = b.Transaction_IDNO,
                            @Lc_Info_CODE = b.Info_qnty
                       FROM CTHB_Y1 b
                      WHERE b.TransHeader_IDNO = @An_TransHeader_IDNO
                            AND b.IVDOutOfStateFips_CODE =   @Ac_IVDOutOfStateFips_CODE
                            AND b.Transaction_DATE = @Ad_Transaction_DATE;

                     --CODE 1 indicates information block is available, 0 indicates info. block is not available.
                     IF (@Lc_Info_CODE = '1')
                        BEGIN
                           SELECT @Ls_InfoLine_TEXT = SUBSTRING (PR.DescriptionComments_TEXT, 1, 400)
                             FROM CSPR_Y1 PR
                            WHERE PR.TransHeader_IDNO = @Ln_Message_IDNO
                                  AND PR.EndValidity_DATE = @Ld_High_DATE;
                        END;
                  END;
            END;

         INSERT INTO #NoticeElementsData_P1
            (Element_NAME, 
             Element_Value)
            (SELECT pvt.Element_NAME, pvt.Element_Value
               FROM (SELECT CONVERT (VARCHAR (400), INFO_DATA_BLOCK_TEXT) INFO_DATA_BLOCK_TEXT
                       FROM (SELECT @Ls_InfoLine_TEXT AS INFO_DATA_BLOCK_TEXT) h) up 
								UNPIVOT (Element_Value FOR Element_NAME IN  
										(UP.INFO_DATA_BLOCK_TEXT)) AS pvt);

         SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
      END TRY
      BEGIN CATCH
         SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
         DECLARE
            @Li_Error_NUMB INT = ERROR_NUMBER (),
            @Li_ErrorLine_NUMB INT = ERROR_LINE ();

         IF (@Li_Error_NUMB <> 50001)
            BEGIN
               SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
            END;

         EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION @As_Procedure_NAME = @Ls_Procedure_NAME,
                                                       @As_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT,
                                                       @As_Sql_TEXT = @Ls_Sql_TEXT,
                                                       @As_Sqldata_TEXT = @Ls_SqlData_TEXT,
                                                       @An_Error_NUMB = @Li_Error_NUMB,
                                                       @An_ErrorLine_NUMB = @Li_ErrorLine_NUMB,
                                                       @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT ;

         SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
      END CATCH;
   END;

GO
