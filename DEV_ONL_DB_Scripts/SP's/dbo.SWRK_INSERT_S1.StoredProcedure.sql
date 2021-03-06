/****** Object:  StoredProcedure [dbo].[SWRK_INSERT_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SWRK_INSERT_S1] (
 @Ac_Worker_ID                CHAR(30),
 @An_TransactionEventSeq_NUMB NUMERIC(19),
 @Ac_SignedOnWorker_ID        CHAR(30)
 )
AS
 /*  
  *     PROCEDURE NAME    : SWRK_INSERT_S1  
  *     DESCRIPTION       : Insert User work schedule information.  
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 01/17/2012
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1.0
 */
 BEGIN
  DECLARE @Ld_Systemdatetime_DTTM DATETIME2 = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
  DECLARE @Ld_Current_DATE DATE = @Ld_Systemdatetime_DTTM;
  DECLARE @Ld_High_DATE DATE ='12/31/9999';
  DECLARE @Ld_BeginWork_DTTM DATETIME2 = '01/01/0001 08:00 AM';
  DECLARE @Ld_EndWork_DTTM DATETIME2 = '01/01/0001 05:00 PM';
  DECLARE @Ld_Break_DTTM DATETIME2 = '01/01/0001 00:00';
  DECLARE @Li_MaxLoad_QNTY INT = 999;
  DECLARE @Li_Count_IDNO INT = 2;
  WHILE (@Li_Count_IDNO <=7)
	BEGIN

	  INSERT SWRK_Y1
			   (Worker_ID,
				Day_CODE,
				
				BeginWork_DTTM,
				EndWork_DTTM,
				BeginBreak1_DTTM,
				EndBreak1_DTTM,
				BeginBreak2_DTTM,
				EndBreak2_DTTM,
				BeginBreak3_DTTM,
				EndBreak3_DTTM,
				
				MaxLoad_QNTY,
				BeginValidity_DATE,
				EndValidity_DATE,
				WorkerUpdate_ID,
				Update_DTTM,
				TransactionEventSeq_NUMB)
	  VALUES ( @Ac_Worker_ID,
			   @Li_Count_IDNO,
			   @Ld_BeginWork_DTTM,
			   @Ld_EndWork_DTTM,
			   @Ld_Break_DTTM,
			   @Ld_Break_DTTM,
			   @Ld_Break_DTTM,
			   @Ld_Break_DTTM,
			   @Ld_Break_DTTM,
			   @Ld_Break_DTTM,
			   @Li_MaxLoad_QNTY,
			   @Ld_Current_DATE,
			   @Ld_High_DATE,
			   @Ac_SignedOnWorker_ID,
			   @Ld_Systemdatetime_DTTM,
			   @An_TransactionEventSeq_NUMB);
			   
		SET @Li_Count_IDNO = @Li_Count_IDNO + 1;
		
	END
 END


GO
