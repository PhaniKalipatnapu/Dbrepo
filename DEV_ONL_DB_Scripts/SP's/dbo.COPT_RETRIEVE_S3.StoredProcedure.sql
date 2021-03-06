/****** Object:  StoredProcedure [dbo].[COPT_RETRIEVE_S3]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[COPT_RETRIEVE_S3]
AS
 /*
  *     PROCEDURE NAME    : COPT_RETRIEVE_S3
  *     DESCRIPTION       : Retrieving County List.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 03-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SELECT C.County_IDNO,
         C.County_NAME
    FROM COPT_Y1 C
   ORDER BY C.County_NAME;
 END; -- END OF COPT_RETRIEVE_S3

GO
