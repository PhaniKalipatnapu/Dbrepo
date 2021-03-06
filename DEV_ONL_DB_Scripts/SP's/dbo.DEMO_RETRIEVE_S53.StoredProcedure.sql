/****** Object:  StoredProcedure [dbo].[DEMO_RETRIEVE_S53]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
 CREATE PROCEDURE [dbo].[DEMO_RETRIEVE_S53]
    (
     @An_MemberSsn_NUMB	NUMERIC(9,0),
     @Ac_Last_NAME		CHAR(20)	OUTPUT,
     @Ac_Suffix_NAME	CHAR(4)		OUTPUT,
     @Ac_First_NAME		CHAR(16)	OUTPUT,
     @Ac_Middle_NAME	CHAR(20)	OUTPUT
     )
AS

/*
 *     PROCEDURE NAME    : DEMO_RETRIEVE_S53
 *     DESCRIPTION       : Retrieve Member_NAME for the respective MemberSsn_NUMB
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 02-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
BEGIN
     SELECT @Ac_Last_NAME   = NULL,
            @Ac_Suffix_NAME = NULL,
            @Ac_First_NAME  = NULL,
            @Ac_Middle_NAME = NULL;

     DECLARE 
            @Ld_High_DATE	DATE = '12/31/9999';
        
     SELECT TOP 1  @Ac_Last_NAME   = b.Last_NAME,
				   @Ac_Suffix_NAME = b.Suffix_NAME,
                   @Ac_First_NAME  = b.First_NAME,
                   @Ac_Middle_NAME = b.Middle_NAME
       FROM MSSN_Y1 a JOIN DEMO_Y1 b
         ON b.MemberMci_IDNO = a.MemberMci_IDNO
      WHERE a.MemberSsn_NUMB = @An_MemberSsn_NUMB 
        AND a.EndValidity_DATE < @Ld_High_DATE;
END; --END OF DEMO_RETRIEVE_S53

GO
