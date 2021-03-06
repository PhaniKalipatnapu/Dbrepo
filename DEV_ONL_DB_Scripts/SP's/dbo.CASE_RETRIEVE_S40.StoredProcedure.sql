/****** Object:  StoredProcedure [dbo].[CASE_RETRIEVE_S40]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE  [dbo].[CASE_RETRIEVE_S40]
( 
  @An_Case_IDNO     NUMERIC(6,0),
  @Ac_File_ID       CHAR(10),
  @Ac_Exists_INDC   CHAR(1)   OUTPUT
)
AS

/*
 *     PROCEDURE NAME    : CASE_RETRIEVE_S40
 *     DESCRIPTION       : Retrieve the Row Count for a Case Idno and Docket Idno.
 *     DEVELOPED BY      : IMP TEAM
 *     DEVELOPED ON      : 02-SEP-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
 */
   BEGIN
      
      DECLARE
           @Lc_Yes_TEXT    CHAR(1) ='Y',
           @Lc_No_TEXT    CHAR(1) ='N';
           
      SET @Ac_Exists_INDC = @Lc_No_TEXT;

     SELECT @Ac_Exists_INDC = @Lc_Yes_TEXT
       FROM CASE_Y1 c
      WHERE c.Case_IDNO = @An_Case_IDNO 
        AND c.File_ID = @Ac_File_ID;

END; --End Of Procedure CASE_RETRIEVE_S40


GO
