/****** Object:  StoredProcedure [dbo].[MPAT_RETRIEVE_S7]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[MPAT_RETRIEVE_S7] (
@An_MemberMci_IDNO NUMERIC(10,0),
@Ad_Birth_DATE     DATE,
@Ai_Count_QNTY     INT OUTPUT
)
AS
 /*
  *     PROCEDURE NAME    : MPAT_RETRIEVE_S7
  *     DESCRIPTION       : Check the member Date of Birth is greater than the Date of Conception
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 08-SEP-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
 
  SET @Ai_Count_QNTY = NULL;
  
  DECLARE @Ld_Low_DATE DATE ='01/01/0001';

 SELECT @Ai_Count_QNTY = COUNT(1)
    FROM MPAT_Y1 c
    WHERE MemberMci_IDNO = @An_MemberMci_IDNO
      AND Conception_DATE > @Ad_Birth_DATE
      AND Conception_DATE <> @Ld_Low_DATE;
    
 END;-- END of MPAT_RETRIEVE_S7

GO
