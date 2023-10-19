
clc
clear all
close all

%number of groups
ngroups=10;
%ngroups=5;
%ngroups=1;


%number of agents
nagents=100;
%nagents=20;

%do end agents overlap? if 0 then local disconnected network; if 1 then
%local connected network
%endagentsoverlap=0;
endagentsoverlap=1;


%Number of crossovers; if greater than 0 then 'small world'
ncrossovers=15;
%ncrossovers=0;

%number of simulations
numsims=100;

%Initializing Vectors of Values that need to be stored for results
%Each vector has the same length as the number of iterations
Vrounds=zeros(numsims,1);
Vtotaltrades=zeros(numsims,1);
Vtotalsearches=zeros(numsims,1);
Vmeanprice=zeros(numsims,1);
Vstdprice=zeros(numsims,1);
Vpath=zeros(numsims,1);
Vmeandegree=zeros(numsims,1);
Vstddegree=zeros(numsims,1);
Minitial_utils=zeros(nagents,numsims);
Mfinal_utils=zeros(nagents,numsims);
Mdegree_cent=zeros(nagents,numsims);
Mcloseness_cent=zeros(nagents,numsims);
Mbetweenness_cent=zeros(nagents,numsims);
Meigen_cent=zeros(nagents,numsims);




%this is the outermost loop
%please note that the only reason Network creation is inside this loop
%rather than outside is because crossovers are randomly placed.  In all the
%models without a crossover, it would be faster to create the network
%outside this loop as the network structure would stay the same for each
%iteration
for sim=1:numsims




    %Initializing Network Adjacency Matrix
    Network=zeros(nagents,nagents);

    %G1 and G2 are the group numbers for each agent: recall that some
    %agents could be in two groups (those who are crossovers in a SWN and
    %endagents in a SWN and LCN)
    G1=zeros(nagents,1);
    G2=zeros(nagents,1);

    %associating each agent with a group(ignoring crossovers and endagents)
    ctr=0;
    for i=1:ngroups
        for j=1:nagents/ngroups
            ctr=ctr+1;
            G1(ctr)=i;
        end
    end

    %associating endagents with a second group
    if endagentsoverlap==1
        G2(1)=ngroups;
        for i=(nagents/ngroups)+1:(nagents/ngroups):(nagents-1)
            G2(i)=G1(i)-1;
        end
    end

    %creating a matrix where the row is the group number
    %agent numbers of each group are stored across the columns
    Groupmems=zeros(ngroups, (nagents/ngroups)+endagentsoverlap);
    %an assumption I have made here is that crossovers can trade with a
    %second group but only belong to one group

    %ctrs - one is needed for each group
    ctrs=zeros(ngroups,1);
    for i=1:nagents

        %storing the agent number of i in the row corresponding to the
        %group of i and updating the counter for that group
        ctrs(G1(i))=ctrs(G1(i))+1;
        Groupmems(G1(i),ctrs(G1(i)))=i;

        if G2(i)~=0
            %storing the agent number of i in the row corresponding to the
            %second group of i (if it exists) and updating the counter
            ctrs(G2(i))=ctrs(G2(i))+1;
            Groupmems(G2(i),ctrs(G2(i)))=i;
        end
    end


    %creating the network based on group affiliation
    for i=1:nagents-1
        for j=i+1:nagents

            if G1(i)== G1(j)
                Network(i,j)=1;
                Network(j,i)=1;
            end

            if endagentsoverlap==1 && (G2(j)==G1(i) || G2(i)==G1(j))
                Network(i,j)=1;
                Network(j,i)=1;
            end

        end
    end


    %if crossovers exist, the following loop updates the Network
    %accordingly.  countcrossovers counts how many crossovers have been
    %implemented
    countcrossovers=0;

    while countcrossovers<ncrossovers

        %first pick a random agent and a randon group to which the agent
        %will be connected
        i=randi(nagents);
        randgroup=randi(ngroups);

        %this agent is a valid crossover only if she does not belong to the
        %group with which she will act as a crossover and no agents can
        %be in more than two groups
        if G1(i)~=randgroup && G2(i) ==0

            G2(i)=randgroup;
            %if the group is valid, then she will establish a link with
            %every member in that group
            for j=1:(nagents/ngroups)+endagentsoverlap
                Network(i,Groupmems(randgroup,j))=1;
                Network(Groupmems(randgroup,j),i)=1;
            end

            %this has been a valid crossover - add to the count of
            %crossovers accomplished
            countcrossovers=countcrossovers+1;
        end

    end

    %drawing network structure if it is first iteration for static network
    %types, and for every iteration if netowrk has a random component
    %(crossovers) across different iterations
    if sim==1 || ncrossovers>0
        figure(1)
        spy(Network)
        title(num2str(sim))
        drawnow

        figure(2)
        G=graph(Network);
        plot(G)
    end



    ShortestPaths=findshortestpaths(Network);
    Vpath(sim)=mean(mean(ShortestPaths));
    Vmeandegree(sim)=mean(sum(Network));
    Vstddegree(sim)=std(sum(Network));



    %Assigning random integers between 10 and 1500 for Good 1 across all
    %agents and assigning random numbers between 10 and 1500 for Good 2
    %across all agents
    good1=randi([10,1500],nagents,1);
    good2=10+1490*rand(nagents,1);


    Minitial_utils(:,sim)=good1.*good2;

    Mdegree_cent(:,sim)=centrality(G,"degree");
    Mcloseness_cent(:,sim)=centrality(G,"closeness");
    Mbetweenness_cent(:,sim)=centrality(G,"betweenness");
    Meigen_cent(:,sim)=centrality(G,"eigenvector");

    %reservation price (always price of G1)
    rprice=good2./good1;
    %storing how prices change across rounds withing each simulation
    Matsimprice=rprice;

    %initializing the count for number of  trades and number of searches to
    %0 before trading begins
    totaltrades=0;
    totalsearches=0;
    %
    %     ShortestPaths=findshortestpaths(Network);
    %     Vpath(sim)=mean(mean(ShortestPaths));
    %     Vmeandegree(sim)=mean(sum(Network));
    %     Vstddegree(sim)=std(sum(Network));



    %start trading rounds
    for rounds = 1:500

        %tradesinround computes number of trades in a particular round.  If
        %no trades occur in a round then the market has reached an
        %equilibrium
        tradesinround=0;

        %the following loop is required because the authors say that a
        %random person from one group is selected, then a random person
        %from another group is selected and so on util a person from
        %each group has been selected.  Then a second person is randomly
        %selected from one group, and then another person, and so on.

        %the following loop randomizes across each row of Groupmems
        for indx=1:ngroups
            tempvec=Groupmems(indx,:);
            tempvec=tempvec(randperm((nagents/ngroups)+endagentsoverlap));
            Groupmems(indx,:)=tempvec;
        end


        for col=1:((nagents/ngroups)+endagentsoverlap)
            %go through each group randomly
            for row=randperm(ngroups)

                %'i' is the person who is beong considered
                i=Groupmems(row,col);

                %initialize the potential utility i could get from a trade
                %with each j as 0s
                potui=zeros(nagents,1);

                %Search across all agents
                for j=1:nagents

                    %if the agent j is not in network, skip
                    if Network(i,j)==0
                        continue
                    end

                    %if agent j is in network, number of searches has
                    %increased by1
                    totalsearches=totalsearches+1;

                    %potequprice is the potential equilibrium price if
                    %agent i were to trade with agent j
                    poteqprice=(good2(i)+good2(j))/(good1(i)+good1(j));

                    %if agent i's reservation price is less that agent j's
                    %reservation price, then agent i will buy g2 (ibuyg2=1)
                    %else agent sell g2 (ibuyg2=-1)
                    if rprice(i)<=rprice(j)
                        ibuysg2=1;
                    else
                        ibuysg2=-1;
                    end
                    %potential utility gained from trading 1 unit at that
                    %price
                    potui(j)=(good2(i)+poteqprice*ibuysg2)*(good1(i)-ibuysg2);

                end

                %once all trading partners have been considered, choose the
                %trading partner from whom i would gain the most by trading
                %one unit.
                [~,chosenj]=max(potui);

                %if agent i's reservation price is less that agent chosenj's
                %reservation price, then agent i will buy g2 (ibuyg2=1)
                %else agent sell g2 (ibuyg2=-1)
                if rprice(i)<=rprice(chosenj)
                    ibuysg2=1;
                else
                    ibuysg2=-1;
                end

                %equilibrium price when agent i trades with agent chosenj
                eqprice=(good2(i)+good2(chosenj))/(good1(i)+good1(chosenj));

                %trade occurs is set to 0. Remember trade only occurs if
                %both agents have their utility increase.
                tradeoccurs=0;

                %trade continues to occur as long as both agents see their
                %utility go up, trading one unit at a time at the set price
                trytotrade=1;
                while trytotrade==1

                    %utility for i from trading one unit
                    uinew=(good2(i)+eqprice*ibuysg2)*(good1(i)-ibuysg2);

                    %utility for chosenj from trading one unit
                    ujnew=(good2(chosenj)-eqprice*ibuysg2)*(good1(chosenj)+ibuysg2);

                    %current utilities
                    uiold=good1(i)*good2(i);
                    ujold=good1(chosenj)*good2(chosenj);

                    %trade only if new utilities exceed current utilities
                    %for both agents
                    if uinew>uiold && ujnew>ujold
                        %update goods and reservation price
                        good2(i)=good2(i)+eqprice*ibuysg2;
                        good2(chosenj)=good2(chosenj)-eqprice*ibuysg2;
                        good1(i)=good1(i)-ibuysg2;
                        good1(chosenj)=good1(chosenj)+ibuysg2;
                        rprice(i)=good2(i)/good1(i);
                        rprice(chosenj)=good2(chosenj)/good1(chosenj);
                        %keep track of the fact that trade has taken place
                        %in this round
                        tradesinround=tradesinround+1;
                        %keep track of the fact that trade has occured for
                        % agent i
                        tradeoccurs=1;
                    else
                        % if no gain in utility for both from trade,
                        %walk away.
                        trytotrade=0;

                    end
                end

                %count up the value of total trades
                totaltrades=totaltrades+tradeoccurs;
            end
        end

        %check to see if any trade occured in this round (note that trades
        %inround was set to 0 at the start of each round).  if no trade
        %occured, break out of this iteration
        if tradesinround==0
            break
        end

        rprice=good2./good1;
        Matsimprice=[Matsimprice,rprice];

    end

    Mfinal_utils(:,sim)=good1.*good2;

    %store the number of rounds during which trade took place in this
    %iteration
    Vrounds(sim)=rounds-1;

    %store the total number of trades that took place in this iteration
    Vtotaltrades(sim)=totaltrades;

    %store the total number of searches that took place in this iteration
    Vtotalsearches(sim)=totalsearches;

    %store the mean final price for this iteration
    Vmeanprice(sim)=mean(rprice);

    %store the standard deviation of final price across agents for this
    %iteration
    Vstdprice(sim)=std(rprice);

    figure(3)
    plot(Matsimprice')
    title(num2str(sim))
    axis([-inf, inf, 0.5, 2]);
    drawnow


end


y=((Mfinal_utils-Minitial_utils)./Minitial_utils);
y=reshape(y,[],1);

xbetween=reshape(Mbetweenness_cent,[],1);
xcloseness=reshape(Mcloseness_cent,[],1);
xdegree=reshape(Mdegree_cent,[],1);
xeigen=reshape(Meigen_cent,[],1);
X=[ones(numsims*nagents,1), xbetween, xcloseness, xdegree,xeigen];

if ncrossovers>0
    [all_b,all_bint]=regress(y,X);
    [between_b,between_bint]=regress(y,[ones(numsims*nagents,1), xbetween]);
    [closeness_b,closeness_bint]=regress(y,[ones(numsims*nagents,1), xcloseness]);
    [degreeb,degree_bint]=regress(y,[ones(numsims*nagents,1), xdegree]);
    [eigenb,eigen_bint]=regress(y,[ones(numsims*nagents,1), xeigen]);

end



