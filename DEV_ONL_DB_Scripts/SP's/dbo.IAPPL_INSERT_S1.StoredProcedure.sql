/****** Object:  StoredProcedure [dbo].[IAPPL_INSERT_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[IAPPL_INSERT_S1](
 @An_Application_IDNO NUMERIC(15, 0) OUTPUT
 )
AS
 /*  
 *      PROCEDURE NAME    : IAPPL_INSERT_S1  
  *     DESCRIPTION       : Generate new Application  
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 12/08/2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
 */
 BEGIN
  DECLARE @Ld_SystemDate_DATE DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

  SET @An_Application_IDNO = NULL;

  INSERT INTO IAPPL_Y1
              (Entered_DATE)
       VALUES (@Ld_SystemDate_DATE);

  SET @An_Application_IDNO = @@IDENTITY;
  
 END


GO
