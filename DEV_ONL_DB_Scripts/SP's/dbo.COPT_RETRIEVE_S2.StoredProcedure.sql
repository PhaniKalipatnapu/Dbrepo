/****** Object:  StoredProcedure [dbo].[COPT_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[COPT_RETRIEVE_S2] (
 @An_County_IDNO NUMERIC(3, 0),
 @Ac_Exists_INDC CHAR(1) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : COPT_RETRIEVE_S2
  *     DESCRIPTION       : Check when the County IDNO EXISTS IN the CountyOptions TABLE. 
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 05-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN  
   DECLARE @Lc_Yes_TEXT  CHAR(1) = 'Y',
           @Lc_No_TEXT   CHAR(1) = 'N';
          
  SET @Ac_Exists_INDC = @Lc_No_TEXT;

  SELECT @Ac_Exists_INDC = @Lc_Yes_TEXT
    FROM COPT_Y1 C
   WHERE C.County_IDNO = @An_County_IDNO;
 END; -- END OF COPT_RETRIEVE_S2


GO
