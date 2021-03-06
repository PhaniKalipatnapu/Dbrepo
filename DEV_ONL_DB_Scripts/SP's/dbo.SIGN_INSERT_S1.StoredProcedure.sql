/****** Object:  StoredProcedure [dbo].[SIGN_INSERT_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE PROCEDURE [dbo].[SIGN_INSERT_S1] (
 @As_ESign_BIN         VARCHAR(4000),
 @Ac_SignedOnWorker_ID CHAR(30),
 @An_ESign_IDNO        NUMERIC(19, 0) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : SIGN_INSERT_S1
  *     DESCRIPTION       : Insert the signature in database in an encoded manner with the generated sequence number.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 25-JAN-2012
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  INSERT SIGN_Y1
         (WorkerUpdate_ID,
          Update_DTTM,
          ESign_BIN)
  VALUES ( @Ac_SignedOnWorker_ID,
           DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
           CONVERT(VARBINARY(4000),@As_ESign_BIN));

  SELECT @An_ESign_IDNO = SCOPE_IDENTITY();
 END; -- End of SIGN_INSERT_S1                       

GO
