/****** Object:  StoredProcedure [dbo].[DCKT_RETRIEVE_S3]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[DCKT_RETRIEVE_S3](
	@Ac_File_ID			CHAR(10),
	@An_County_IDNO		NUMERIC(3)		OUTPUT,
	@Ac_County_NAME		CHAR(40)		OUTPUT,
	@Ad_Filed_DATE		DATE			OUTPUT
	)
AS

/*
 *     PROCEDURE NAME    : DCKT_RETRIEVE_S3
 *     DESCRIPTION       : Retrives the County Details and Filed Date for a given File ID.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 02-MAR-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/

   BEGIN

      SELECT @An_County_IDNO = c.County_IDNO, 
      		 @Ac_County_NAME = b.County_NAME,
			 @Ad_Filed_DATE = c.Filed_DATE
      FROM DCKT_Y1 c
		JOIN COPT_Y1 b
			ON b.County_IDNO = c.County_IDNO
      WHERE c.File_ID = @Ac_File_ID;

                  
END; --DCKT_RETRIEVE_S3


GO
