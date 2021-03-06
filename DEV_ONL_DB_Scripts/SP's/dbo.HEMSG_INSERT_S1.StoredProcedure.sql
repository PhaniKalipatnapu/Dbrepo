/****** Object:  StoredProcedure [dbo].[HEMSG_INSERT_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[HEMSG_INSERT_S1] (
 @Ac_Error_CODE CHAR(18)
 )
AS
 /*
  *     Procedure Name    : HEMSG_INSERT_S1
  *     Description       : Insert a give Error Message record into History table
  *     Developed By      : IMP Team 
  *     Developed On      : 03-AUG-2011
  *     Modified By       : 
  *     Modified On       : 
  *     Version No        : 1
 */
 BEGIN
  DECLARE @Ld_Systemdatetime_DTTM DATETIME2 = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

  INSERT HEMSG_Y1
         (Error_CODE,
          DescriptionError_TEXT,
          TypeError_CODE,
          BeginValidity_DATE,
          EndValidity_DATE,
          TransactionEventSeq_NUMB,
          Update_DTTM,
          WorkerUpdate_ID)
  SELECT E.Error_CODE,
         E.DescriptionError_TEXT,
         E.TypeError_CODE,
         E.BeginValidity_DATE,
         @Ld_Systemdatetime_DTTM,
         E.TransactionEventSeq_NUMB,
         @Ld_Systemdatetime_DTTM,
         E.WorkerUpdate_ID
    FROM EMSG_Y1 E
   WHERE E.Error_CODE = @Ac_Error_CODE;
 END; --End of HEMSG_INSERT_S1

GO
