/****** Object:  StoredProcedure [dbo].[DEMO_RETRIEVE_S93]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DEMO_RETRIEVE_S93] (
 @An_MemberMci_IDNO				NUMERIC(10,0),
 @An_MemberMciSecondary_IDNO	NUMERIC(10,0),
 @Ai_Count_QNTY		 			INT OUTPUT
 )
AS

/*
 *     PROCEDURE NAME    : DEMO_RETRIEVE_S93
 *     DESCRIPTION       : Retrieve the count of records from Member Demographic table for Unique number assigned by the system to the participant (This is the ID value that will replace with the secondary DCN in all the tables that have this member ID) and Unique number assigned by the system to the participant (This is the ID value that will be searched and replaced by the primary member ID in all the tables that have this member ID as a column) with Secondary Members date of birth NOT equal to High Date (31-DEC-9999) or Low Date (01-JAN-0001) and NOT different from Primary Members date of birth (or) Secondary Members date of birth equal to High Date (31-DEC-9999) or Low Date (01-JAN-0001) and FACTS Unique ID assigned to the Secondary Members DCN is NOT null and equal to FACTS Unique ID assigned to the Primary Members DCN (or) FACTS Unique ID assigned to the Secondary Members DCN is null and their Last Name, First Name and Middle Initial are the same.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 20-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
 BEGIN

	SET @Ai_Count_QNTY = NULL;

 DECLARE @Ld_High_DATE 	DATE = '12/31/9999', 
         @Ld_Low_DATE	DATE = '01/01/0001';
        
 SELECT @Ai_Count_QNTY = COUNT(1)
   FROM DEMO_Y1 dmp
        JOIN
        DEMO_Y1 dms
     ON dmp.Last_NAME = dms.Last_NAME    
    AND dmp.First_NAME = dms.First_NAME  
    AND dmp.Middle_NAME = dms.Middle_NAME
  WHERE dmp.MemberMci_IDNO = @An_MemberMci_IDNO 
    AND dms.MemberMci_IDNO = @An_MemberMciSecondary_IDNO 
    AND ((dms.Birth_DATE NOT IN ( @Ld_High_DATE, @Ld_Low_DATE ) 
          AND dmp.Birth_DATE = dms.Birth_DATE ) 
        OR dms.Birth_DATE IN ( @Ld_High_DATE, @Ld_Low_DATE )); 
                     
END; -- END OF DEMO_RETRIEVE_S93


GO
