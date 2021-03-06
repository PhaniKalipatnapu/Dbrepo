/****** Object:  StoredProcedure [dbo].[IDOCS_INSERT_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[IDOCS_INSERT_S1](
 @An_Seq_IDNO NUMERIC(8, 0) OUTPUT
 )
AS
 /*  
 *      PROCEDURE NAME    : IDOCS_INSERT_S1  
  *     DESCRIPTION       : Generate new Document ID  
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 03/19/2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
 */
 BEGIN
  DECLARE @Ld_SystemDate_DATE DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

  SET @An_Seq_IDNO = NULL;

  DELETE FROM IDOCS_Y1;

  INSERT INTO IDOCS_Y1
              (Entered_DATE)
       VALUES (@Ld_SystemDate_DATE);

  SELECT @An_Seq_IDNO = ID.Seq_IDNO
    FROM IDOCS_Y1 ID;
 END


GO
