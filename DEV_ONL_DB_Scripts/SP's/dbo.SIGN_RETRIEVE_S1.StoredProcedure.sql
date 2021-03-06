/****** Object:  StoredProcedure [dbo].[SIGN_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
 

CREATE PROCEDURE [dbo].[SIGN_RETRIEVE_S1] (
 @An_ESign_IDNO  NUMERIC(19, 0),
 @As_ESign_BIN VARCHAR(4000) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : SIGN_RETRIEVE_S1
  *     DESCRIPTION       : Retrieves the E-Signature information for the given E-Signature Idno.
  *     DEVELOPED BY      : IMP Team 
  *     DEVELOPED ON      : 25-JAN-2012
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @As_ESign_BIN = NULL; 
  
  
  SELECT @As_ESign_BIN =  CONVERT(VARCHAR(4000),S.ESign_BIN)
    FROM SIGN_Y1 S
   WHERE S.ESign_IDNO = @An_ESign_IDNO;
 END; --End Of SIGN_RETRIEVE_S1

GO
