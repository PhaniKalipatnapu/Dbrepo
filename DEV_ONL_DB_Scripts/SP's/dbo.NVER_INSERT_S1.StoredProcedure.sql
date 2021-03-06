/****** Object:  StoredProcedure [dbo].[NVER_INSERT_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[NVER_INSERT_S1] (
 @Ac_Notice_ID                CHAR(8),
 @An_NoticeVersion_NUMB       NUMERIC(5, 0),
 @As_XslTemplate_TEXT         VARCHAR(MAX),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0),
 @Ac_SignedOnWorker_ID        CHAR(30)
 )
AS
 /*                                                                            
  *     PROCEDURE NAME    : NVER_INSERT_S1                                      
  *     DESCRIPTION       : Insert details into Notice Version Reference table.
  *     DEVELOPED BY      : IMP Team                                         
  *     DEVELOPED ON      : 10-AUG-2011                                        
  *     MODIFIED BY       :                                                    
  *     MODIFIED ON       :                                                    
  *     VERSION NO        : 1                                                  
 */
 BEGIN
  DECLARE @Ld_High_DATE DATE ='12/31/9999';

  INSERT NVER_Y1
         (Notice_ID,
          NoticeVersion_NUMB,
          XslTemplate_TEXT,
          Effective_DATE,
          End_DATE,
          WorkerUpdate_ID,
          TransactionEventSeq_NUMB,
          Update_DTTM)
  VALUES ( @Ac_Notice_ID,
           @An_NoticeVersion_NUMB,
           @As_XslTemplate_TEXT,
           dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
           @Ld_High_DATE,
           @Ac_SignedOnWorker_ID,
           @An_TransactionEventSeq_NUMB,
           dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME() );
 END; -- End Of NVER_INSERT_S1                                                                            

GO
