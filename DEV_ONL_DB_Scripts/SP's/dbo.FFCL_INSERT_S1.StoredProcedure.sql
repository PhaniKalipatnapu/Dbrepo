/****** Object:  StoredProcedure [dbo].[FFCL_INSERT_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[FFCL_INSERT_S1] (
 @Ac_Function_CODE            CHAR(3),
 @Ac_Action_CODE              CHAR(1),
 @Ac_Reason_CODE              CHAR(5),
 @Ac_Notice_ID                CHAR(8),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0),
 @Ac_SignedOnWorker_ID        CHAR(30)
 )
AS
 /*
  *     PROCEDURE NAME    : FFCL_INSERT_S1
  *     DESCRIPTION       : Insert all the Far Form Check List details. 
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 25-OCT-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_Current_DATE        DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Ld_Systemdatetime_DTTM DATETIME2 = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Ld_High_DATE   		  DATE = '12/31/9999';

  INSERT FFCL_Y1
         (Function_CODE,
          Action_CODE,
          Reason_CODE,
          Notice_ID,
          BeginValidity_DATE,
          EndValidity_DATE,
          WorkerUpdate_ID,
          TransactionEventSeq_NUMB,
          Update_DTTM)
  VALUES ( @Ac_Function_CODE,
           @Ac_Action_CODE,
           @Ac_Reason_CODE,
           @Ac_Notice_ID,
           @Ld_Current_DATE,
           @Ld_High_DATE,
           @Ac_SignedOnWorker_ID,
           @An_TransactionEventSeq_NUMB,
           @Ld_Systemdatetime_DTTM );
 END; --END OF FFCL_INSERT_S1  


GO
